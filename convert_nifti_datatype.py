import os
import argparse
import nibabel

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input-filename', help='Path to the input file to convert')
    parser.add_argument('-o', '--output-filename', help='Path to save the converted file')
    args = parser.parse_args()
    infn = args.input_filename
    outfn = args.output_filename

    # Load the file
    img = nibabel.load(infn)
    print("Original dtype:", img.get_data_dtype())

    # Change the datatype
    img.set_data_dtype(float)
    print("Modified dtype:", img.get_data_dtype())

    # Save to the new file
    img.to_filename(outfn)


if __name__ == "__main__":
    main()
