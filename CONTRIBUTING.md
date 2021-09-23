<!-- TOC -->

- [Contributing](#contributing)
- [About Visual Code (VSCode)](#about-visual-code-vscode)

<!-- TOC -->

# Contributing

* Install the following packages: ``git`` and a text editor of your choice. By default, the use of **VSCode is recommended**.
* Configure authentication on your Github account to use the SSH protocol instead of HTTP. Watch this tutorial to learn how to set up: https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
* Create a fork this repository.
* Clone the forked repository to your local system.
* Add a Git remote for the original repository.

```bash
git remote -v
git remote add upstream git@github.com:rafaelperoco/kind.git
git remote -v
```

* Create a branch using the pattern: `git checkout -b BRANCH_NAME`. Example: *git checkout -b mybranch*
* Make your changes to the new branch.
* Test your changes in *development* environment.
* Commit the changes to the branch.
* Push files to repository remote with command `git push --set-upstream origin BRANCH_NAME`. Example: *git push --set-upstream origin BRANCH_NAME*
* Create Pull Request (PR) to the `main` branch. See this [tutorial](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)
* Update the content with the suggestions of the reviewer (if necessary).
* After your pull request is merged, update your local clone.

```bash
git checkout main
git pull upstream main
```

* Clean up after your pull request is merged with command `git branch -d <branch name>`. Example: *git branch -d BRANCH_NAME*
* Then you can update the ``main`` branch in your forked repository.

```bash
git push origin main
```

* And push the deletion of the feature branch to your GitHub repository with command `git push --delete origin <branch name>`. Example: *git push --delete origin BRANCH_NAME*
* To keep your fork in sync with the original repository, use these commands:

```bash
git pull upstream main
git push origin main
```

Reference:
* https://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/

# About Visual Code (VSCode)

VSCode (https://code.visualstudio.com), combined with the following plugins, helps the editing/review process, mainly allowing the preview of the content before the commit, analyzing the Markdown syntax and generating the automatic summary, as the section titles are created/changed.

Plugins to Visual Code:

* docker: https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker (require docker-ce package)
* gitlens: https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens (require git package)
* go: https://marketplace.visualstudio.com/items?itemName=golang.Go (require go package)
* gotemplate-syntax: https://marketplace.visualstudio.com/items?itemName=casualjim.gotemplate
* jenkinsfile support: https://marketplace.visualstudio.com/items?itemName=ivory-lab.jenkinsfile-support
* Markdown-all-in-one: https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one
* Markdown-lint: https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint
* Markdown-toc: https://marketplace.visualstudio.com/items?itemName=AlanWalk.markdown-toc
* python: https://marketplace.visualstudio.com/items?itemName=ms-python.python (require python3 package)
* shellcheck: https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck (require shellcheck package)
* terraform: https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform (require terraform package)
* YAML: https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml
* Helm Intellisense: https://marketplace.visualstudio.com/items?itemName=Tim-Koehler.helm-intellisense

Theme for VSCode:

* https://code.visualstudio.com/docs/getstarted/themes
* https://dev.to/thegeoffstevens/50-vs-code-themes-for-2020-45cc
* https://vscodethemes.com/
