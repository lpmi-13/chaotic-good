# Chaotic Good Scenarios on AWS

This will be a very truncated demonstration of 3-5 (probably 3) example scenarios in an AWS environment that break and require fixing. The object is to authentically simulate what happens during an outage in a real production environment.

## Context

To make it as authentic as possible, we will have:

-   Running services (probably something simple like web tier, application tier, and DB tier)
-   Alerts (the medium needs to be decided on, but will probably go with discord for now)
-   Dashboards (Grafana fed with prometheus for the servers/DBs)
-   Logs (ideally we'd have a full ELK stack, but not sure how easily this would be to set up)

## Environment

This will be actual resources deployed in an actual AWS environment (as opposed to all running locally, which is a separate focus of this same project). So we'll need some things to enable identity and access management.

We'll need temporary access credentials (a few different ways to do this, so need to settle on one), as well as SSH keys in case we need to access the VMs. We might set up a bastion at the edge of the network, though this could potentially be overkill for an MVP demo.

## Organization

`/infra`

-   we have all the terraform resources defined here, and this is where the apply and destroy scripts will be. It's also where we define the terraform resources for the different tiers (eg, the stuff on cloudfront/ECS/RDS)

`/frontend`

-   this has the frontend, which is just a static site that communicates with the backend. It's deployed to cloudfront via the automation code in `/infra`.

`/api`

-   this has the application layer, that sits in fargate (probably), served behind a load balancer.

`/monitoring`

-   this is all the tooling around monitoring and observability, primarily metrics with prometheus/grafana and logging via ELK. It's possible this might end up in the `/infra` folder.

## Provisioning

This will be fully automated via terraform, and maybe even using terraform cloud, since it's free up to 5 users. We also need some way to tear everything down at the end, but still working out the best way to do this (probably just manually from the terraform cloud console).

_UPDATE:_ For now, this is going to be in separate steps, since I don't feel like fighting ansible with the terraform provisioners, at the moment, and wrapping it all in a shell script is going to effectively get me to one command deploy/configuration anyway.

### steps

first, create some ssh keys for the instances:

```
bash create-keys.sh
```

then the terraform provisioning in this file:

```
bash apply.sh
```

...and to tear down everything at the end:

```
bash destroy.sh
```

## Tests

-   make sure we have billing alerts enabled
-   make sure we have locked down permissions for specific resources
-   assert against common security issues

TODO: Let's put in some governance and policy assertions just to make sure things stay how we want them.

## Scenarios

The idea is to let somebody access the AWS environment and maybe poke around for a bit before receiving an alert via discord (or slack or pagerduty or whatever's easy to integrate). The alert will direct them to a problem, and then we go from there, troubleshooting and testing hypotheses until the issue is resolved.

Some types of problems might be a bit more difficult to set up than others. For example, a simulation of a change failure that needs to be rolled back would probably need to involve interacting with the build system, and that would probably exist outside of AWS (the source code definitely would). So we might look into setting up an organization on GitHub solely for the purpose of allowing somebody to see releases and either rollback or fix forward, and then perhaps integrate that with Travis/Circle/etc, but that's far out of scope for the MVP.

The easiest thing to do would be to target scenarios that involve failures based on external factors like load/networking/instances going down (for whatever reason).

Based on the above, the very simple outline of the scenarios we'll be targeting for the MVP are as follows:

-   Database (either RDS or self-hosted on EC2) gets overloaded and can't respond fast enough to prevent 5XXs from the application server.
-   The database runs out of connections and stops responding to requests.
-   A security group gets updated and takes down the connection between the application and the data backing service.
-   One of the EC2 instances (or we might also play around with ECS a bit) crashes (maybe cause it's a long running instance and the underlying hardware fails, or AWS just decides to move the VM).
-   Something (either VM or container) fills up with logs and can't write, then crashes
-   On EKS (EC2 instance type), we can simulate not having enough EC2 instance resources in our cluster to scale along with load, and then we start sending back 5XXs (similar to the Database issue, but at the application level)
-   Similar to above, but with IP address space (it's possible that both would require very tiny EC2 instances, and be triggered the same way, so potentially not worth doing as separate scenarios).

## Feedback

For the early stages, this will most likely just be manual, though eventually, it would be nice if we can trigger a _success_ message or something based on a particular metric (or the absence of one indicating a problem).

It would also be nice to have the system track behavior with times/activity/etc to formulate a very basic timeline for a post-mortem template, but maybe that's a bit too much process for what's intended to be a very straightforward MVP.

## Practical Design Considerations

Since the eventual goal is to have this streamed publicly, we don't necessarily want to have something that's instantly DDoS-able. So we need several sorts of authentication involved.

-   Both the admin and the player need to have distinct AWS login credentials, probably just single-use provisioned IAM Users, maybe with 2FA enabled.
-   For interacting with the frontend, we would benefit from some sort of additional authentication, since this will be a public site, throughout the duration of the exercise. Maybe something with a Cognito pool that just has two people in it. Ideally, we'd have something that spins up with the exercise and gets destroyed at the end, in which case Cognito sounds good...though allegedly very poorly documented.
