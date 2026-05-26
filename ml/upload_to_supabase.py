#!/usr/bin/env python3
import os
import re
import json
import urllib.request
import urllib.error
from pathlib import Path

# Config paths
SCRIPT_DIR = Path(__file__).parent
WORKSPACE_ROOT = SCRIPT_DIR.parent
DART_REGISTRY_PATH = WORKSPACE_ROOT / "lib" / "models" / "standards_registry.dart"

def parse_clause_fields(clause_str):
    """
    Extracts structured fields from a raw Dart PlumbingStandardClause string.
    """
    m_code = re.search(r"standardCode:\s*['\"](.*?)['\"],", clause_str)
    m_clause = re.search(r"clauseNumber:\s*['\"](.*?)['\"],", clause_str)
    m_title = re.search(r"title:\s*['\"](.*?)['\"],", clause_str)
    m_category = re.search(r"category:\s*['\"](.*?)['\"],", clause_str)
    
    # Capture summaryText (handles both standard quotes and Dart multi-line triple-quotes)
    m_summary = re.search(r"summaryText:\s*'''(.*?)'''|summaryText:\s*['\"](.*?)['\"]", clause_str, re.DOTALL)
    summary = ""
    if m_summary:
        summary = m_summary.group(1) or m_summary.group(2) or ""
        summary = summary.strip()
        
    # Capture list of technical metrics
    m_metrics = re.search(r"technicalMetrics:\s*\[(.*?)\]", clause_str, re.DOTALL)
    metrics = []
    if m_metrics:
        metrics = re.findall(r"['\"](.*?)['\"]", m_metrics.group(1))
        
    # Capture list of compliance checklists
    m_checklist = re.search(r"complianceChecklist:\s*\[(.*?)\]", clause_str, re.DOTALL)
    checklist = []
    if m_checklist:
        checklist = re.findall(r"['\"](.*?)['\"]", m_checklist.group(1))
        
    if m_code and m_clause and m_title and m_category:
        return {
            "standard_code": m_code.group(1),
            "clause_number": m_clause.group(1),
            "title": m_title.group(1),
            "category": m_category.group(1),
            "summary_text": summary,
            "technical_metrics": metrics,
            "compliance_checklist": checklist
        }
    return None

def parse_dart_file(file_path):
    """
    Parses standards_registry.dart to extract all static PlumbingStandardClause instances.
    """
    print(f"Reading and parsing Dart file: {file_path}")
    if not file_path.exists():
        print(f"Error: {file_path} not found.")
        return []
        
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
        
    clauses = []
    start_indices = [m.start() for m in re.finditer(r"PlumbingStandardClause\(", content)]
    
    for start_idx in start_indices:
        idx = start_idx + len("PlumbingStandardClause(")
        paren_count = 1
        clause_str = ""
        while idx < len(content) and paren_count > 0:
            char = content[idx]
            if char == '(':
                paren_count += 1
            elif char == ')':
                paren_count -= 1
            clause_str += char
            idx += 1
            
        if clause_str.endswith(')'):
            clause_str = clause_str[:-1]
            
        clause = parse_clause_fields(clause_str)
        if clause:
            clauses.append(clause)
            
    print(f"Successfully extracted {len(clauses)} clauses from registry!")
    return clauses

def get_gemini_embedding(text, api_key):
    """
    Queries Google Gemini API to get a 768-dimension vector embedding for the input text.
    """
    url = f"https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key={api_key}"
    headers = {
        "Content-Type": "application/json"
    }
    payload = {
        "model": "models/text-embedding-004",
        "content": {
            "parts": [{"text": text}]
        }
    }
    
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST"
    )
    
    try:
        with urllib.request.urlopen(req) as res:
            response_data = json.loads(res.read().decode("utf-8"))
            return response_data["embedding"]["values"]
    except urllib.error.HTTPError as e:
        print(f"Gemini embedding request failed: {e.code} - {e.read().decode('utf-8')}")
        raise e
    except Exception as e:
        print(f"Error calling Gemini Embedding API: {e}")
        raise e

def upload_to_supabase(clause_data, embedding, supabase_url, service_key):
    """
    Inserts or updates the clause and its vector embedding in the Supabase db via REST interface.
    """
    url = f"{supabase_url.rstrip('/')}/rest/v1/standards_embeddings"
    headers = {
        "apikey": service_key,
        "Authorization": f"Bearer {service_key}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal"
    }
    
    # Combine standard fields and embedding
    payload = {
        **clause_data,
        "embedding": embedding
    }
    
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST"
    )
    
    try:
        with urllib.request.urlopen(req) as res:
            return True
    except urllib.error.HTTPError as e:
        print(f"Supabase upload request failed: {e.code} - {e.read().decode('utf-8')}")
        raise e
    except Exception as e:
        print(f"Error calling Supabase: {e}")
        raise e

def main():
    print("=================================================================")
    print("AquaForge Cloud Vector Sync: Plumbing Standards Registry")
    print("=================================================================")
    
    # Load keys
    gemini_key = os.environ.get("GEMINI_API_KEY")
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_service_key = os.environ.get("SUPABASE_SERVICE_KEY")
    
    # Try parsing .env file if environment variables aren't set
    env_path = WORKSPACE_ROOT / ".env"
    if env_path.exists() and (not gemini_key or not supabase_url or not supabase_service_key):
        print("Reading credentials from local .env file...")
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                if "=" in line and not line.strip().startswith("#"):
                    k, v = line.strip().split("=", 1)
                    if k == "GEMINI_API_KEY" and not gemini_key:
                        gemini_key = v
                    elif k == "SUPABASE_URL" and not supabase_url:
                        supabase_url = v
                    elif k == "SUPABASE_SERVICE_KEY" and not supabase_service_key:
                        supabase_service_key = v

    if not gemini_key:
        print("Error: GEMINI_API_KEY environment variable or .env key is missing.")
        return
        
    if not supabase_url or not supabase_service_key:
        print("\n[WARNING] Supabase environment variables (SUPABASE_URL / SUPABASE_SERVICE_KEY) are missing.")
        print("Please configure them in your .env file to sync to the remote database.")
        print("Example configuration:")
        print("SUPABASE_URL=https://your-project-id.supabase.co")
        print("SUPABASE_SERVICE_KEY=your-supabase-service-role-key-goes-here\n")
        return
        
    # 1. Parse standards registry
    clauses = parse_dart_file(DART_REGISTRY_PATH)
    if not clauses:
        return
        
    # 2. Iterate and sync each standard
    print("\nSynchronizing Vector Vault...")
    success_count = 0
    for idx, clause in enumerate(clauses, 1):
        clause_title = f"{clause['standard_code']} - {clause['clause_number']} ({clause['title']})"
        print(f"[{idx}/{len(clauses)}] Processing: {clause_title}")
        
        # Build document text context to generate embedding from
        metrics_str = ", ".join(clause["technical_metrics"])
        checklist_str = "; ".join(clause["compliance_checklist"])
        text_context = (
            f"Standard: {clause['standard_code']}\n"
            f"Clause: {clause['clause_number']}\n"
            f"Title: {clause['title']}\n"
            f"Category: {clause['category']}\n"
            f"Summary: {clause['summary_text']}\n"
            f"Technical Metrics: {metrics_str}\n"
            f"Compliance Checklist: {checklist_str}"
        )
        
        try:
            # Get embedding from Gemini
            embedding = get_gemini_embedding(text_context, gemini_key)
            
            # Upload/insert into Supabase
            upload_to_supabase(clause, embedding, supabase_url, supabase_service_key)
            success_count += 1
        except Exception as e:
            print(f"  --> Failed to sync clause: {e}")
            
    print("\n=================================================================")
    print(f"Sync complete! Successfully uploaded {success_count}/{len(clauses)} standards.")
    print("=================================================================")

if __name__ == "__main__":
    main()
