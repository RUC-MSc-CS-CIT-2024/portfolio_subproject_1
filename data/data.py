import os

# Function to split files
def split_file(file_path, chunk_size=50 * 1024 * 1024):
    chunk_num = 1
    chunk_files = []
    
    with open(file_path, 'rb') as file:
        while True:
            chunk = file.read(chunk_size)
            if not chunk:
                break
            chunk_file_name = f"{file_path}.part{chunk_num}"
            with open(chunk_file_name, 'wb') as chunk_file:
                chunk_file.write(chunk)
            chunk_files.append(chunk_file_name)
            chunk_num += 1
    print(f"{file_path} has been split into {len(chunk_files)} parts.")
    return chunk_files

# Function to reassemble files
def reassemble_files(part_files, output_file):
    with open(output_file, 'wb') as outfile:
        for part_file in part_files:
            with open(part_file, 'rb') as infile:
                outfile.write(infile.read())
    print(f'Reassembled file saved as {output_file}')

# Example usage
# List of files to split
files_to_split = ['imdb.backup', 'wi.backup', 'omdb_data.backup']

# Split each file
for file_path in files_to_split:
    split_file(file_path)

# Reassemble example
imdb_parts = [f'imdb.backup.part{n}' for n in range(1, 4)]
wi_parts = [f'wi.backup.part{n}' for n in range(1, 4)]
omdb_parts = [f'omdb_data.backup.part{n}' for n in range(1, 3)]

# Reassemble the parts into their original files
reassemble_files(imdb_parts, 'imdb_reassembled.backup')
reassemble_files(wi_parts, 'wi_reassembled.backup')
reassemble_files(omdb_parts, 'omdb_data_reassembled.backup')
