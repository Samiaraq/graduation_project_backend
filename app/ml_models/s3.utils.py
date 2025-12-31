import os
import boto3


def ensure_model_file(filename: str, subdir: str = "models") -> str:
    """
    Ensure model file exists locally.
    If not, download it from S3.

    Env vars required:
      S3_BUCKET
      AWS_ACCESS_KEY_ID
      AWS_SECRET_ACCESS_KEY
      AWS_REGION (optional)
    """

    bucket = os.getenv("S3_BUCKET")
    if not bucket:
        raise RuntimeError("Missing env var: S3_BUCKET")

    base_dir = os.path.join(os.path.dirname(__file__), subdir)
    os.makedirs(base_dir, exist_ok=True)

    local_path = os.path.join(base_dir, filename)
    if os.path.exists(local_path):
        return local_path

    s3 = boto3.client(
        "s3",
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
        region_name=os.getenv("AWS_REGION"),
    )

    print(f"Downloading {filename} from S3 bucket {bucket} ...")
    s3.download_file(bucket, filename, local_path)

    return local_path