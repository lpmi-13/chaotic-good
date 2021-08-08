# Chaotic Good Scenarios on AWS

This will be a very truncated demonstration of 3-5 (probably 3) example scenarios in an AWS environment that break and require fixing. The object is to authentically simulate what happens during an outage in a real production environment.

## Context

To make it as authentic as possible, we will have:

- Running services (probably something simple like web tier, application tier, and DB tier)
- Alerts (the medium needs to be decided on, but will probably go with discord for now)
- Dashboards (Grafana fed with prometheus for the servers/DBs)
- Logs (ideally we'd have a full ELK stack, but not sure how easily this would be to set up)

## Environment

This will be actual resources deployed in an actual AWS environment (as opposed to all running locally, which is a separate focus of this same project). So we'll need some things to enable identity and access management.

We'll need temporary access credentials (a few different ways to do this, so need to settle on one), as well as SSH keys in case we need to access the VMs. We might set up a bastion at the edge of the network, though this could potentially be overkill for an MVP demo.

## Provisioning

This will be fully automated via terraform, and maybe even using terraform cloud, since it's free up to 5 users. We also need some way to tear everything down at the end, but still working out the best way to do this (probably just manually from the terraform cloud console).

## Tests

- make sure we have billing alerts enabled
- make sure we have locked down permissions for specific resources
- assert against common security issues

TODO: Let's put in some governance and policy assertions just to make sure things stay how we want them.

## Scenarios

The idea is to let somebody access the AWS environment and maybe poke around for a bit before receiving an alert via discord (or slack or pagerduty or whatever's easy to integrate). The alert will direct them to a problem, and then we go from there, troubleshooting and testing hypotheses until the issue is resolved.

Some types of problems might be a bit more difficult to set up than others. For example, a simulation of a change failure that needs to be rolled back would probably need to involve interacting with the build system, and that would probably exist outside of AWS (the source code definitely would). So we might look into setting up an organization on GitHub solely for the purpose of allowing somebody to see releases and either rollback or fix forward, and then perhaps integrate that with Travis/Circle/etc, but that's far out of scope for the MVP.

The easiest thing to do would be to target scenarios that involve failures based on external factors like load/networking/instances going down (for whatever reason).

Based on the above, the very simple outline of the scenarios we'll be targeting for the MVP are as follows:

- Database (either RDS or self-hosted on EC2) gets overloaded and can't respond fast enough to prevent 5XXs from the application server.
- A security group gets updated and takes down the connection between the application and the data backing service.
- One of the EC2 instances (or we might also play around with ECS a bit) crashes (maybe cause it's a long running instance and the underlying hardware fails, or AWS just decides to move the VM).
- On ECS (EC2 launch type), we can simulate not having enough EC2 instance resources in our cluster to scale along with load, and then we start sending back 5XXs (similar to the Database issue, but at the application level)

## Feedback

For the early stages, this will most likely just be manual, though eventually, it would be nice if we can trigger a *success* message or something based on a particular metric (or the absence of one indicating a problem).

It would also be nice to have the system track behavior with times/activity/etc to formulate a very basic timeline for a post-mortem template, but maybe that's a bit too much process for what's intended to be a very straightforward MVP.
