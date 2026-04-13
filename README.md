<!--
   SPDX-FileCopyrightText: 2001 Monaco F. J. <https://github.com/monacofj>
  
   SPDX-License-Identifier: CC-BY-SA-4.0

   This file is part of SYSeg, available at https://github.com/monacofj/syseg.
-->

_SYSeg - Copyright (c) 2021 Monaco F. J. <https://github.com/monacofj>_ 

_SYSeg is released under the GNU General Public License v3.0 or later. See  
Licensing terms below for details._ 

SYSeg - System Software by Example
========================================

SYSeg (System Software, e.g.) is a compilation of source-code examples and
programming exercises illustrating general concepts and techniques related to
system-software design and implementation, drawn from university-level Computer
Science and Engineering courses taught by the author.

The content may be useful to both students and instructors working with
low-level programming, either as a complementary reference for a structured
teaching program or as a self-learning resource for those pursuing a
ground-up understanding of:

- how build tools work internally to transform source code into machine code;
- what is inside an executable program and how it interacts with other software;
- how the inner workings of operating systems and related tools are implemented.

Featured topics include the Application Binary Interface (ABI), runtime systems,
build toolchains (compiler, assembler, linker), dynamic loading, shared
libraries, address relocation, position-independent code (PIC), the POSIX
standard, file systems, and build automation, among others.

The official SYSeg repository is at https://github.com/monacofj/syseg.

Quick start
-----------------------------------------------

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

Content overview
------------------------------

The project root contains the following top-level subdirectories:

- `eg` main source-code examples
- `try` suggested programming exercises
- `tools` auxiliary tools used by examples and exercises
- `docs` SYSeg documentation
- `arcane` esoteric features, forbidden arts, and hacker lore
- `draft` work-in-progress material (potentially incomplete)

Each of these subdirectories includes a `README` file that further explains
its contents and provides guidance on how to explore it.

**Note**: this repository is an ongoing complete refactoring of SYSeg v0.1.0. 
The migration is being carried out in stages, so some parts of the former 
release may still be unavailable here. 

Documentation
------------------------------

Please see:

- `docs/syseg.md` for further usage instructions
- `AUTHORS` for the list of authors and contribution acknowledgements
- `docs/ai_policy.md` for AI assistance disclosure and intellectual integrity
- `CONTRIBUTING.md` for information on how to contribute to this project

Feedback
------------------------------

If you have used SYSeg for self-study, in a course, or as part of a teaching
program, the author would be very glad if you could drop a note to say that the
material has been useful.

Also, the low-level landscape is often shaped by subtle details, historical
quirks, and intricate platform-specific behavior. Despite every effort,
technical problems or conceptual inaccuracies may still have passed unnoticed.
If you come across anything of the sort, please consider reporting it.

Licensing
-------------------------------
 
SYSeg is free software: you can redistribute it and/or modify it under 
the terms of the GNU General Public License, either version 3 of the License, 
or (at your option) any later version. You should have received a copy of the 
GNU General Public License along with this software.  If not, see 
<https://www.gnu.org/licenses/>

Some third-party components or specific files may be licensed under different 
terms. Please consult each file's header and the LICENSES/ directory for 
precise details. 

