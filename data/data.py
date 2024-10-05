import os

def reassemble_files(part_files, output_file):
    with open(output_file, 'wb') as outfile:
        for part_file in part_files:
            with open(part_file, 'rb') as infile:
                outfile.write(infile.read())
    print(f'Reassembled file saved as {output_file}')

imdb_parts = [f'imdb.backup.part{n}' for n in range(1, 4)]
wi_parts = [f'wi.backup.part{n}' for n in range(1, 4)]
omdb_parts = [f'omdb_data.backup.part{n}' for n in range(1, 3)]

reassemble_files(imdb_parts, 'imdb.backup')
reassemble_files(wi_parts, 'wi.backup')
reassemble_files(omdb_parts, 'omdb_data.backup')
