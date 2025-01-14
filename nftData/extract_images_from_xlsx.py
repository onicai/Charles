import zipfile
import os

# Path to the .xlsx file
xlsx_file = 'temp.xlsx'

# Directory to store extracted images
output_dir = "extracted_images"
os.makedirs(output_dir, exist_ok=True)

# Open the .xlsx file as a zip file
with zipfile.ZipFile(xlsx_file, 'r') as archive:
    # Loop through the archive to find image files
    for file in archive.namelist():
        if file.startswith('xl/media/'):  # Excel stores images in the xl/media folder
            # Extract and save the image file
            image_path = os.path.join(output_dir, os.path.basename(file))
            with open(image_path, 'wb') as img_file:
                img_file.write(archive.read(file))
            print(f"Extracted {file} to {image_path}")

print("All images extracted.")