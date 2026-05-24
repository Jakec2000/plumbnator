import os
import json
import re
import fitz  # PyMuPDF
from pathlib import Path

# Setup paths relative to the script's execution context (assumes running from workspace root)
ROOT_DIR = Path(__file__).parent.parent
DOCS_DIR = ROOT_DIR / "docs" / "standards"
ASSETS_DIR = ROOT_DIR / "assets" / "standards"
OUTPUT_JSON = ASSETS_DIR / "parsed_standards.json"

def clean_text(raw_text):
    """
    Normalizes excessive whitespace and newline characters from PDF raw dumps.
    """
    if not raw_text:
        return ""
    # Replace multiple spaces with a single space
    text = re.sub(r'[ \t]+', ' ', raw_text)
    # Replace multiple newlines with a single newline to preserve some paragraph structure
    text = re.sub(r'\n\s*\n', '\n\n', text)
    return text.strip()

def chunk_text(text, max_chars=2000):
    """
    Splits text into smaller, more manageable chunks for the AI engine,
    respecting paragraph breaks where possible.
    """
    paragraphs = text.split('\n\n')
    chunks = []
    current_chunk = ""
    
    for para in paragraphs:
        if len(current_chunk) + len(para) > max_chars and current_chunk:
            chunks.append(current_chunk.strip())
            current_chunk = para
        else:
            current_chunk += "\n\n" + para if current_chunk else para
            
    if current_chunk:
        chunks.append(current_chunk.strip())
        
    return chunks

def parse_standards():
    print(f"Starting parsing of PDF standards in {DOCS_DIR}...")
    
    if not DOCS_DIR.exists():
        print(f"Error: {DOCS_DIR} does not exist.")
        return
        
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    
    parsed_data = {}
    
    # Recursively find all PDFs
    pdf_files = list(DOCS_DIR.rglob("*.pdf"))
    
    for pdf_path in pdf_files:
        filename = pdf_path.name
        folder_name = pdf_path.parent.name
        key_name = f"{folder_name}/{filename}"
        print(f"Processing {key_name}...")
        
        try:
            doc = fitz.open(str(pdf_path))
            document_text = ""
            
            # Extract text from all pages
            for page in doc:
                page_text = page.get_text()
                if page_text:
                    document_text += page_text + "\n\n"
                    
            # Clean and chunk
            cleaned_text = clean_text(document_text)
            chunks = chunk_text(cleaned_text)
            
            # Store in structured dictionary
            parsed_data[key_name] = {
                "title": filename.replace(".pdf", ""),
                "folder": folder_name,
                "total_pages": len(doc),
                "chunks": chunks
            }
            
            print(f"  - Extracted {len(chunks)} text chunks across {len(doc)} pages.")
            doc.close()
            
        except Exception as e:
            print(f"Failed to process {key_name}: {e}")
            
    # Dump to JSON
    print(f"\nSaving structured data to {OUTPUT_JSON}...")
    with open(OUTPUT_JSON, "w", encoding="utf-8") as f:
        json.dump(parsed_data, f, ensure_ascii=False, indent=2)
        
    print("Parsing completed successfully!")

if __name__ == "__main__":
    parse_standards()
