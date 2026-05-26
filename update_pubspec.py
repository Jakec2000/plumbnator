import os

file_path = "lib/providers/state_providers.dart"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# I will write a simple python script that just drops the google_generative_ai line from pubspec.yaml
with open("pubspec.yaml", "r", encoding="utf-8") as f:
    pubspec = f.read()

pubspec = pubspec.replace("  google_generative_ai: ^0.4.7\n", "")

with open("pubspec.yaml", "w", encoding="utf-8") as f:
    f.write(pubspec)

print("Updated pubspec.yaml")
