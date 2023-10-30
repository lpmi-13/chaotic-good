# Frontend for Chaotic-Good

This is the basic frontend that gets served from cloudfront. A GitHub action runs on merge to main and uploads the assets to cloudfront.

## Content

This is a very basic site that shows reviews to customers for random products, and allows them to log into their account to manage their own reviews.

It consumes from an API (located in the `/backend` folder) and uses that to display data in the frontend.

## Technical details

Because this is intended to be used as a one-off practice exercise, the subdomain that it's available on is randomized (a la GitPod or Netlify), for example, if you're using a top-level domain like `chaotic-good.org`, the cloudfront resource will be something like:

```
j38dER4FFk9dlel21.chaotic-good.org
```

While developing locally, you can just visit `localhost:8080`.
