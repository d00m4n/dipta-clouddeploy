gcloud compute instances list --format="get(name)" | xargs gcloud compute instances delete --quiet
