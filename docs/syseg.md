<!--
SPDX-FileCopyrightText: 2021 Monaco F. J. <https://github.com/monacofj>

SPDX-License-Identifier: CC-BY-SA-4.0

This file is part of SYSeg (https://github.com/monacofj/syseg)
-->

SYSeg Manual
==============================

TL;DR

As part of an undergraduate scientific program at the university, the author
did some research work at the Institute of Physics. There was a huge and
intimidating high-tech precision-measurement device that looked like an alien
artifact straight out of a sci-fi movie. On a stainless-steel tag attached to
the device, a short, subtly ironic note read:

_"After all solo assembling attempts have failed, read the instruction manual"._


Introduction
-----------------------------

SYSeg (System Software, e.g.) is a compilation of source-code examples and
programming exercises illustrating general concepts and techniques related to
system-software design and implementation, drawn from university-level Computer
Science and Engineering courses taught by the author.

The official SYSeg repository is at https://github.com/monacofj/syseg.

Quick start
-----------------------------

Most code examples in this project require auxiliary artifacts that must be
built beforehand. Proceed as follows, depending on whether you are using the
development version cloned from the repository (which always reflects the latest
updates) or a release package downloaded as a compressed archive (corresponding
to a particular vX.Y.Z release).

1. If you cloned the repository, you will need to bootstrap the project's
   build infrastructure and then configure and build the tools.

```
   cd syseg
   ./bootstrap.sh
   ./configure
   make
```

   The scripts may prompt you to install a few required tools.

2. If you downloaded a release package, it should already include the build
   infrastructure, so you will only need to configure and build the tools.

```
   cd syseg
   ./configure
   make
```

Essential Information
------------------------------

* Each subdirectory in the source tree has a file `README` which contains
important instructions on how to use the directory's contents.

* SYSeg was developed and tested on the GNU/Linux operating system. Most 
tools and code examples that are not hardware-dependent should presumably
work on other POSIX compatible OSes. There have been reports of users
successfully testing examples on FreeBSD, macOS, and even on WSL, or on
Linux inside a virtual machine. None of those setups has been systematically
tested, though. If you run into trouble with a particular setup, your feedback
will be much appreciated.

* Low-level code examples are often inherently architecture-dependent. Most 
examples in SYSeg are currently targeted at the x86 platform and may not apply 
to other hardware. There are also ongoing examples covering different platforms 
such as Arduino and ESP32, among others. The README file in the example
directory indicates the targeted platform.

Exporting code from SYSeg
--------------------------------

If you want to reuse any code example outside the SYSeg tree, do not simply
copy the files elsewhere. They need to be prepared so that they also work
outside the SYSeg tree.

A common use case is to copy an exercise into your own Git repository, for
example as part of an assignment.

In that case, *enter the directory you want to export*, and, *from there*, run

```
make export DEST=path/to/own/repo
```

This will create `path/to/own/repo` as a standalone copy of the files and
tools needed for manual builds. The exported example can then be built
manually without depending on the SYSeg source tree.

If you create new files or modify exported files in your own repository,
update the copyright notice to credit both the original SYSeg project, if
applicable, and the authors of the local changes. The exported tree includes
its own `tools/prepfile` script to help with that. Run it from inside the
exported directory.

For example, if you modified file `foo` in the exported tree,

```
../tools/prepfile foo
```



Troubleshooting
---------------------------------

Each example comes with a README with usage information and directions to
solve most difficulties. 

If you still have problems, leave a note in the project's issue tracker.
