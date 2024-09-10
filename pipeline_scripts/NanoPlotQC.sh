while [[ "$#" -gt 0 ]]; do
    case $1 in
        --reads) reads="$2"; shift ;;
        --input_type) input_type="$2"; shift ;;
        --out_dir) out_dir="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

mkdir -p ${out_dir}
NanoPlot --only-report -o ${out_dir} --${input_type} ${reads} 

