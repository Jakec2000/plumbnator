import os
import fitz  # PyMuPDF

src_dir = r"C:\Users\Jczek\OneDrive\Desktop\Plumbing Standards\New folder"
dst_dir = r"c:\Users\Jczek\.antigravity\plumbing apps\plumbnator\assets\standards"

os.makedirs(dst_dir, exist_ok=True)

for file in os.listdir(src_dir):
    if file.lower().endswith(".pdf"):
        src_file = os.path.join(src_dir, file)
        txt_file = os.path.join(dst_dir, file[:-4] + ".txt")
        print(f"Extracting text from {file} to {txt_file}...")
        try:
            doc = fitz.open(src_file)
            text = ""
            for page in doc:
                text += page.get_text() + "\n"
            
            with open(txt_file, "w", encoding="utf-8") as f:
                f.write(text)
            print(f"Successfully wrote {len(text)} characters to {txt_file}")
        except Exception as e:
            print(f"Error parsing {file}: {e}")

print("Extraction complete!")
