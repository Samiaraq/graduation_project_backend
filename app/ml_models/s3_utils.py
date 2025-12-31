import boto3
import os
def ensure_model_file(filename: str, subdir: str = "models") -> str:
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

    # 🔴 لا strip ولا لعب
    key = f"{subdir}/{filename}"

    print(f"Downloading from S3: bucket={bucket}, key={key}")

    s3.download_file(bucket, key, local_path)

    return local_path