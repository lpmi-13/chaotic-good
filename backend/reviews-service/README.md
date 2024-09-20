# Unnamed Node Service

I have no idea what this service will do, but wanted to set one up following the excellent [guide](https://www.learnwithjason.dev/blog/modern-node-server-typescript-2024) from Jason Lengstorf.

It most likely will eventually be instrumented to send opentelemetry data.

## Running Locally

First, copy `.env.example` to `.env` and put in the actual value(s) you need.

```sh
npm install
npm run dev
```

## Pushing to ECR

Ideally, this would have a GitHub Action workflow defined, but for simplicity, you can just run `build-and-push.sh` to get it in there. We'll probably move the ECR repository terraform config into a place where it doesn't get torn down constantly so we don't have to start from scratch every time.
