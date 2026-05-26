
import os
import shutil
from pypdf import PdfReader

src_dir = r"C:\Users\Jczek\OneDrive\Desktop\Plumbing Standards\New folder"
dst_dir = r"c:\Users\Jczek\.antigravity\plumbing apps\plumbnator\assets\standards"

os.makedirs(dst_dir, exist_ok=True)

for file in os.listdir(src_dir):
    if file.endswith(".pdf"):
        src_file = os.path.join(src_dir, file)
        dst_file = os.path.join(dst_dir, file)
        
        print(f"Copying {file}...")
        shutil.copy2(src_file, dst_file)
        
        txt_file = os.path.join(dst_dir, file.replace(".pdf", ".txt"))
        print(f"Extracting text to {txt_file}...")
        try:
            reader = PdfReader(src_file)
            text = ""
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
            with open(txt_file, "w", encoding="utf-8") as f:
                f.write(text)
        except Exception as e:
            print(f"Error parsing {file}: {e}")
print("Done!")

