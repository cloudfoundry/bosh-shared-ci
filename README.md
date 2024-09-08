# Bosh Shared CI Tasks

These tasks are maintained by the Foundation Infrastructure Working Group but are intended to be used
by all areas of Cloud Foundry.

Objectives:
- Task interfaces are stable and we will try to avoid introducing breaking changes to the tasks.
- Task inputs and properties are documented in the task `yml` file.
- Task `yml` files include the `image_resource` needed to run the task. However, it is probably a good idea
to copy this into a resource in your pipeline and fetch it separately so you can provide docker credentials and
avoid rate limiting.

## Task Groups

### Release

---
**check-for-patched-cves**  
This task is intended to be used as a release trigger. The task will scan the `input_repo` for CVEs and then compare
that list of CVEs with the CVEs found by checking out the release tag provided by the `version` input. If the list is
different, a CVE has been fixed and the task succeeds.

As Concourse provides no conditional branching logic, it gets a bit tricky to trigger a new release when a CVE has
been patched, but also avoid having the `check-for-patched-cves` job be red all the time. Below is an example that
can be used to accomplish this in a clean-ish way. The `check-for-patched-cves` is wrapped in a `try` step, and then
an `on_success` step hook is used to modify a resource. The Concourse job that actually does the releasing can then
trigger off new versions of that resource. It's also possible to just put the release steps direction within the
`on_success` step hook, but that can get messy if there is a large number of steps.

```yaml
- try:
    task: check-for-patched-cves
    file: bosh-shared-ci/tasks/release/check-for-patched-cves.yml
    input_mapping:
      input_repo: my-repo
      version: my-version-resource
    on_success:
      put: my-time-trigger-resource
```

Since the `check-for-patched-cves` task is in a `try` step, it's possible that the task is actually failing, rather
than exiting 1 because there are no patched CVEs. To guard against that, look at the `ensure-cve-checker-succeeded` task.

The task includes the output file `release-notes/needs-release`. If you have a series of steps in your release pipeline
each of them doing different checks, this file can be used after they have all run to see if a release is needed.

---
**ensure-cve-checker-succeeded**
This task can be used to ensure the `check-for-patched-cves` task was able to successfully scan for patched CVEs.
Since that task is often used in a `try` step, it is a good idea to make sure it didn't fail for other reasons.

The task will exit 1 if the `check-for-patched-cves` step failed. Make sure this task is NOT run in a `try` step.
