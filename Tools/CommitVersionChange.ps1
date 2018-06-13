# Variables for the version number change commit back to GitHub
$ModuleName = $env:BUILD_DEFINITIONNAME
$ModulePath = ".\" + $ModuleName + "\" + $ModuleName + ".psd1"
$PesterResultsPath = ".\Results\" + "PesterResults" + ".xml"
$PSSAResultsPath = ".\Results\" + "PSSAResults" + ".xml"
$CodeCoverageResultsPath = ".\Results\" + "CodeCoverageResults" + ".xml"
$ReadMeUpdatePath = ".\" + "ReadMe" + ".md"

# Git for the version number change commit back to GitHub
git config user.email "matt.collins@node-it.com"
git config user.name "TheMattCollins0"
# git checkout master
git add "$ModulePath"
git add "$PesterResultsPath"
git add "$PSSAResultsPath"
git add "$CodeCoverageResultsPath"
git add "$ReadMeUpdatePath"
git commit -m "Updated Version Number ***NO_CI***"
git push origin HEAD:master
