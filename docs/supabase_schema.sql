-- 1. Enable pgvector extension to store and search machine learning embeddings
create extension if not exists vector;

-- 2. Create the plumbing standards vector storage table
create table if not exists public.standards_embeddings (
  id bigint generated always as identity primary key,
  standard_code text not null,
  clause_number text not null,
  title text not null,
  category text not null,
  summary_text text not null,
  technical_metrics text[] not null,
  compliance_checklist text[] not null,
  embedding vector(768) not null, -- 768 dimensions matches Gemini text-embedding-004 model size
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Enable Row Level Security (RLS) and create public read policy
alter table public.standards_embeddings enable row level security;

create policy "Allow public read-only access to plumbing standards" 
  on public.standards_embeddings 
  for select 
  using (true);

-- 4. Create the semantic match function for cosine similarity searches
create or replace function public.match_standards (
  query_embedding vector(768),
  match_threshold float,
  match_count int
)
returns table (
  id bigint,
  standard_code text,
  clause_number text,
  title text,
  category text,
  summary_text text,
  technical_metrics text[],
  compliance_checklist text[],
  similarity float
)
language sql stable
as $$
  select
    standards_embeddings.id,
    standards_embeddings.standard_code,
    standards_embeddings.clause_number,
    standards_embeddings.title,
    standards_embeddings.category,
    standards_embeddings.summary_text,
    standards_embeddings.technical_metrics,
    standards_embeddings.compliance_checklist,
    1 - (standards_embeddings.embedding <=> query_embedding) as similarity
  from standards_embeddings
  where 1 - (standards_embeddings.embedding <=> query_embedding) > match_threshold
  order by standards_embeddings.embedding <=> query_embedding
  limit match_count;
$$;
