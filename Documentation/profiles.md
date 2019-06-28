# Container Profiles

The security of a container is influenced by its configuration. They are
several parameters:

- *Namespaces:* each kind of namespace (cgroup, ipc, mnt, net, pid, user, uts)
  could be shared with the host or unshared. Some namespaces can have their own
  configuration (e.g. uid mappings for user namespaces).
- *User:* root or non-root
- *Cgroups:* each kind of cgroup subsystem can have specific configuration
  (e.g. `devices` cgroup subsystem)
- *seccomp:* some system calls are restricted in the container
- *Linux Security Modules (LSMs):* AppArmor, SELinux
- *Volumes:* e.g. a host volume

Offering a test environment for all possible configuration would be a
combinational explosion. Instead, the Container Escape Bounty project defines a
few _container profiles_ with predefined configurations. Security researchers
can then start containers under one container profile. The bounty reward could
be different depending on which container profiles the vulnerability is
exploitable on.

The basic container profiles are the following:
- *Default Docker*
- *Weak Docker*
- *Default/Weak Docker with User Namespaces*

Each basic container profiles have the following variants:
- *without LSM*
- *with SELinux*
- *with Apparmor*

## Description of each container profile

### Default Docker

The entrypoint of the provided container image is run as user `nobody`.
As usual, the container processes run in different namespaces as the host processes,
except for the user namespace.

- Namespaces
  - `cgroup`: new (container cgroup becomes new root cgroup)
  - `ipc`: new
  - `mnt` (mounts): new
  - `net`: new
  - `pid`: new (mapped to host PIDs)
  - `user`: of host
  - `uts` (hostname, …): new

The profile uses the `no-new-privileges` flag to prevent processes from geting
new privileges when using `fork`, `clone`, or `exec`.

A `seccomp` policy is used to only allow certain syscalls.
[Here](https://github.com/moby/moby/blob/238f8eaa31aa74be843c81703fabf774863ec30c/profiles/seccomp/default.json)
is the list of allowed syscalls and allowed syscalls when having a `SYS_…` capability.

### Weak Docker

Same as the default profile, but the entrypoint of the provided container image is run as user `root`.
The capabilities `NET_ADMIN` and `SYS_PTRACE` are given in addition to the
[default list](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities).
Note that even though `root` is used, any other capabilities such as `SYS_ADMIN` are not given.

*Shared folder:* The folder `/var/tmp/shared` is shared from the host to the container as a writable bind mount.

### Default/Weak Docker with User Namespaces

These profiles allow the user to start a container with its own user namespace.

Differences from the default/weak docker profile:

* The processes in the container run as root of the user namespace of containers.

* User mapping is done in `/proc/self/uid_map` as following:

```
0     100000      65536
```

* The following kinds of namespaces are owned by the user namespace of the container:

  - ipc
  - mnt
  - net
  - pid
  - uts

* The following kinds of namespaces are owned by the root user namespace:

  - user
  - cgroup


### Without LSM

TODO

### With SELinux

TODO

### With AppArmor

TODO

## Examples of vulnerabilities and relation with container profiles

The purpose of giving a few examples is to discuss whether the current
container profiles are relevent: if the vulnerabilities above were not already
discovered, would they be exploitable in the test environments?

### CVE-2015-3630: Read/write proc paths & CIFS

One aspect of this vulnerability is that "CIFS volumes could be forced into a
protocol downgrade attack by a root user operating inside of a container"
([source](https://packetstormsecurity.com/files/131835/Docker-Privilege-Escalation-Information-Disclosure.html)).

CIFS volumes are not used in the test environments. Also, this vulnerability
would not allow to capture the flag file on the host.

### Escaping from host bind mount (Linux <= 4.2)

When a host volume is made available in the container, files outside of the
volume could still be accessible if a subdirectory is moved accross the mount
boundary.

This was a bug in Linux, fixed by [commit 397d425dc26da728396e66d392d5dcb8dac30c37](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=397d425dc26da728396e66d392d5dcb8dac30c37).

If this bug was still present in recent Linux, it would not be exploitable here
because we don't have processes running on the host moving directories around.

However, this motivated the addition of a host volume in the _Weak Docker_
container profile. We now have a profile where similar bugs could be discovered.

### CVE-2017-1002101: Kubernetes volume subpath

This vulnerability is in Kubernetes instead of Linux. However, this shows that
host volumes could be a source of vulnerabilities.

### CVE-2019-5736: runc breakout

An attacker needs to control the container image and “docker exec” to exploit
the vulnerability.

