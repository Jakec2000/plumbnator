import os

def split_providers():
    input_file = "lib/providers/state_providers.dart"
    output_dir = "lib/providers"
    
    with open(input_file, "r", encoding="utf-8") as f:
        lines = f.readlines()
        
    common_imports = "".join(lines[0:10])

    files_and_ranges = {
        "jobs_provider.dart": (10, 97),
        "sizing_provider.dart": (97, 313),
        "swms_provider.dart": (313, 420),
        "ai_analysis_provider.dart": (420, 536),
        "nav_provider.dart": (536, 550),
        "backflow_provider.dart": (550, 630),
        "assistant_provider.dart": (630, 763),
        "solar_compliance_provider.dart": (763, 1057),
        "stormwater_compliance_provider.dart": (1057, 1249),
        "gas_compliance_provider.dart": (1249, 1433)
    }

    for filename, (start, end) in files_and_ranges.items():
        file_content = common_imports + "\n" + "".join(lines[start:end])
        path = os.path.join(output_dir, filename)
        with open(path, "w", encoding="utf-8") as f:
            f.write(file_content)
        print(f"Created {path}")

    # Now rewrite state_providers.dart to export all these files
    exports = "\n".join([f"export '{filename}';" for filename in files_and_ranges.keys()])
    with open(input_file, "w", encoding="utf-8") as f:
        f.write(exports + "\n")
    print(f"Updated {input_file} to export all providers")

if __name__ == "__main__":
    split_providers()
