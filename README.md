# Pipeline Setup

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) must be installed and running on your system.

## Building the Docker Image

### 1. **Download the `dockerfile`**  
   You can [download it directly](https://github.com/UW-Lutz-Lab/tbSeq_pipeline/blob/master/dockerfile) from the GitHub repository.

<br>
   
### 2. **Navigate to the directory containing the `dockerfile`:**

```bash
   cd /path/to/downloaded/dockerfile
```
<br>

### 3. Build the Docker image:
```bash
docker buildx build -t <YOUR_IMAGE_NAME> .
```

### 4. Configure Your Run

a. Download the `nextflow.config` file from the [GitHub repository.](https://github.com/UW-Lutz-Lab/tbSeq_pipeline/blob/master/nextflow.config) This file controls all paths and parameters for your run.

b. Prepare Directory Structure:

```text
project/
├── dockerfile
├── nextflow.config
├── sample_sheet.csv
├── references/
│   └── rpoB_ref.fasta
│   └── ...
├── reads/
│   ├── sample1.bam
│   ├── sample2.bam
└───└── ...
```
- Reference files in a directory (e.g., references/)

- Demultiplexed BAM files in a directory (e.g., demultiplexed_reads/)

- A sample sheet CSV (e.g., tbSeq05_sample_sheet.csv) describing your samples

<br>

### Sample Sheet Format

The sample sheet **must be a CSV file** with the following columns, and **a header row**:

| alias         | read_filepath    | ref_filepath  |
|---------------|------------------|---------------|
| sample_1      | barcode01.bam    | ref1.fasta    |
| sample_2      | barcode02.bam    | ref2.fasta    |

<br>

**Required columns:**
- `alias` — sample name or ID
- `read_filepath` — **File name only** of the BAM file for this sample  
  *(The pipeline will prepend the directory path from `base_dir` in your config)*
- `ref_filepath` — reference FASTA file name  
  *(The pipeline will prepend the directory path from `reference_base_dir` in your config)*

<br>

**Notes:**
- The file must be comma-separated (`.csv`).
- The header must be present.
- Do **not** include directory paths in `read_filepath` or `ref_filepath`; only the file names.

### 5. Run the Pipeline

Use the following command to run the pipeline with Docker:

```bash
docker run -it \
  -v "$PWD:/mnt" \
  -v "/tmp:/tmp" \
  -e NXF_GITHUB_USER=<username> \
  -e NXF_GITHUB_TOKEN=<token> \
  <docker_image_tag> \
  nextflow run -w /tmp/nf_work UW-Lutz-Lab/tbSeq_pipeline
```

- `-v "$PWD:/mnt"`

    Mounts your current working directory on your host into /mnt inside the container.

    All your data, config, and output files inside your project directory are accessible as /mnt within the container.
This is why paths in your nextflow.config should start with /mnt/.

- `-v "/tmp:/tmp"`

    Mounts your host machine’s /tmp directory to /tmp in the container.

    This lets Nextflow’s work directory be stored outside OneDrive and remain accessible on your host, but separate from your main data.

- `-e NXF_GITHUB_USER=<username>, -e NXF_GITHUB_TOKEN=<token>`

    Pass your GitHub credentials to Nextflow (required for pipelines or modules hosted in private GitHub repos).

- `<docker_image_tag>`

    Replace this with the name of your Docker image (e.g., my_pipeline_image).

- `nextflow run -w /tmp/nf_work UW-Lutz-Lab/tbSeq_pipeline`

    Runs Nextflow inside the container, using /tmp/nf_work as the working directory and launching the pipeline straight from GitHub.
