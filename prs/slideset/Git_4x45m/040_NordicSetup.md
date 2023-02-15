
# Nordic's Setup

## Outline
- [BitBucket](https://projecttools.nordicsemi.no/bitbucket/dashboard)
- [NoRRIS](https://projecttools.nordicsemi.no/confluence/display/QPDA/NoRRIS+Manual)
- [Dogit](https://projecttools.nordicsemi.no/confluence/display/SIG/dogit+reference+documentation)
- [Jenkins](https://jenkins-sig-ip.nordicsemi.no/)
- [dotfiles](https://dotfiles.github.io/)
- Q and A

## BitBucket 1of2
- Nordic pays Atlassian for the enterprise version of BitBucket.
- You can use the free version for personal projects.
- Alternatives include GitLab and Microsoft's GitHub.
- Atlassian also supply Jira and Confluence.
- Recently migrated from on-premises (Norway) setup to the cloud.

## BitBucket 2of2
- Hooks prevent rewriting history, like amending pushed commits.
- Hooks enforce branch our naming scheme.
- Markdown is rendered on all web views.
  - README, commit messages, pull requests
- PDF is also viewable in the web browser, but not DOCX.
- SVG,PNG,JPG are rendered, but not VSDX.
  - SVG can be diffed -- [Inkscape](https://inkscape.org/) is recommended for
    most diagrams and [Wavedrom](https://wavedrom.com/) for waveforms.
  - Visio obfuscates SVG!

## NoRRIS 1of2
- It's a SemVer constraint solver.
  - **Compliance with SemVer is essential!**
- Tightly integrated with BitBucket and SIG's repo structure.
- The [manual](https://projecttools.nordicsemi.no/confluence/display/QPDA/NoRRIS+Manual)
  is detailed and has video tutorials.
- Written and maintained by Berend Dekens.
  - See DDD team for general support.
- Nordic-specific tool, not publically available.

## NoRRIS 2of2
- You've used SemVer constraint solvers before - in package managers like
  `apt` (Debian), `rpm` (RHEL/CentOS), `cargo` (Rust), `pip` (Python).
  - **Compliance with SemVer is essential!**
- Use NoRRIS to avoid the error-prone process of writing XML.
- YAML (`abc/requirements.yaml`) as input, XML (`abc/YourIp.xml`) as output.
- YAML should be hand-written.
- XML is used by dogit to specify dependencies.

## Dogit 1of3
- It's a git-based workspace mangagment tool.
- Fundamentally based around BitBucket, git, and NoRRIS.
- The [manual](https://projecttools.nordicsemi.no/confluence/display/SIG/dogit+reference+documentation)
  is out of date and of limited usefulness to newcomers.
- Written by Ruben Undheim, and maintained by Fredrik Fagerheim.
  - Call them directly for support.
- Based on a combination of [Ruben's home project](https://github.com/rubund/git-ro-cache)
  and another Nordic tool called Doconfig that was based on SVN.
- Nordic-specific tool, not publically available.

## Dogit 2of3
- Terminology is similar to git, but very different in meaning.
- "TTB"
  - A git repo on BitBucket which has a file `.../abc/Foo.xml`.
- "workspace"
  - A directory, `${VC_WORKSPACE}`, created and owned by you.
  - Contains a configuration file `.recipe`.
  - Created using `dogit ip|projectbranch|product`.
- "projectbranch"
  - A name for git branches, which is common to many repos.
  - An entry in the MySQL database with name and pointer to an XML.
  - E.g. `feature/VegaDevelopment2_HM-19446`.
- "product"
  - A workspace configuration (`.recipe`) file that is tracked in the
    [Dogit Support repo](https://projecttools.nordicsemi.no/bitbucket/projects/SIG-DOGIT/repos/methodology_designkit_scripts_dogit--support/browse/recipes).
  - E.g. `VegaSOC1`, `HaltiumSuper`, `Moonlight`.
- "cache" a read-only NFS disk containing all in-use git repos.
  - `/pro/dogit/archive/gitrocache5/`

## Dogit 3of3
- Create a workspace for working on an IP.
  - `dogit ip FooBar`
- Create a workspace for working on a project.
  - `dogit projectbranch feature/FooBar_JIRAKEY-1234`
  - The distinction between an IP and a project isn't well defined.
- Change a symlink (to the cache) to a local repo.
  - `dogit rw`
- Update all the repos in a workspace.
  - `dogit up`
- Push all of your RW repos in a workspace at once.
  - Double check you're not going to break anything.
  - Triple check all changes in all modified repos!
  - `dogit push`
- Anything else?
  - Ask Ruben Undheim first!

## Jenkins 1of1
- <https://github.com/jenkinsci>
- A continuous integration tool.
- Free, open-source software written in Java.
- Configured with `abc/jobconfig.yaml`.
  - ... [demo](https://jenkins-sig-ip.nordicsemi.no/job/IP/job/IP_CoexistenceController/) ...
- Nordic's instance is managed by Yngve Skogsiede.
  - See DDD team for general support.

## Dotfiles 1of1
- <https://dotfiles.github.io/>
- An open source project for tracking configuration files.
- Nordic maintains its own
  [fork](https://projecttools.nordicsemi.no/bitbucket/projects/SIG/repos/dotfiles/browse).
  - See the DDD team for support.
- Should be setup as part of the Digital Design
  [IntroProject](https://projecttools.nordicsemi.no/confluence/pages/viewpage.action?pageId=15767249).
- The aliases `vc`, `tools`, and `rw` are (almost) essential.

## Q and A
- You've all been at Nordic for a while.
- What have you found clear or confusing in that time?

