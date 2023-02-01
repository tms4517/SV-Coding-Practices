
# Nordic's Setup

## Outline
- [BitBucket](https://projecttools.nordicsemi.no/bitbucket/dashboard)
- [NoRRIS](https://projecttools.nordicsemi.no/confluence/display/QPDA/NoRRIS+Manual)
- [Dogit](https://projecttools.nordicsemi.no/confluence/display/SIG/dogit+reference+documentation)
- [Jenkins](https://jenkins-sig-ip.nordicsemi.no/)
- [dotfiles](https://dotfiles.github.io/)

- Practical usage.
  - dotfiles/ucfg
  - Inkscape/Visio
  - Markdown/Word

## BitBucket 1ofTODO
- Nordic pays Atlassian for the enterprise version of BitBucket.
- You can use the free version for personal projects.
- Alternatives include GitLab and Microsoft's GitHub.
- Atlassian also supply Jira and Confluence.
- Recently migrated from on-premises (Norway) setup to the cloud.

## BitBucket 2ofTODO
- Hooks prevent rewriting history, like amending pushed commits.
- Hooks enforce branch naming scheme.
- Markdown is rendered on all web views.
- SVG,PNG,JPG are rendered, but not VSDX.
  - SVG can be diffed -- [Inkscape](https://inkscape.org/) is recommended for
    most diagrams and [Wavedrom](https://wavedrom.com/) for waveforms.
  - Visio obfuscates SVG -- Avoid!

## NoRRIS 1ofTODO
- It's a SemVer constraint solver.
- YAML (`abc/requirements.yaml`) as input, XML (`abc/YourIp.xml`) as output.
- Written by Berend Dekens.
  - See DDD team for general support.

## Dogit 1ofTODO
- It's a git-based workspace mangagment tool.
- Written by Ruben Undheim, and maintained by Fredrik Fagerheim.
  - See DDD team for general support.

## Jenkins 1ofTODO
- It's a continuous integration tool.
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

