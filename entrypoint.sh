#! /usr/bin/env bash

# shellcheck disable=SC2086,SC2164,SC2012,SC2004

unset JAVA_HOME

mkdir -p ./${INPUT_GH_PAGES}
mkdir -p ./${INPUT_ALLURE_HISTORY}
cp -r ./${INPUT_GH_PAGES}/. ./${INPUT_ALLURE_HISTORY}

REPOSITORY_OWNER_SLASH_NAME=${INPUT_GITHUB_REPO}
REPOSITORY_NAME=${REPOSITORY_OWNER_SLASH_NAME##*/}
GITHUB_PAGES_WEBSITE_URL="https://${INPUT_GITHUB_REPO_OWNER}.github.io/${REPOSITORY_NAME}"

if [[ ${INPUT_SUBFOLDER} != '' ]]; then
	INPUT_ALLURE_HISTORY="${INPUT_ALLURE_HISTORY}/${INPUT_SUBFOLDER}"
	INPUT_GH_PAGES="${INPUT_GH_PAGES}/${INPUT_SUBFOLDER}"
	echo "NEW allure history folder ${INPUT_ALLURE_HISTORY}"
	mkdir -p ./${INPUT_ALLURE_HISTORY}
	GITHUB_PAGES_WEBSITE_URL="${GITHUB_PAGES_WEBSITE_URL}/${INPUT_SUBFOLDER}"
	echo "NEW github pages url ${GITHUB_PAGES_WEBSITE_URL}"
fi

if [[ ${INPUT_REPORT_URL} != '' ]]; then
	GITHUB_PAGES_WEBSITE_URL="${INPUT_REPORT_URL}"
	echo "Replacing github pages url with user input. NEW url ${GITHUB_PAGES_WEBSITE_URL}"
fi

COUNT=$( (ls ./${INPUT_ALLURE_HISTORY} | wc -l))
echo "count folders in allure-history: ${COUNT}"
echo "keep reports count ${INPUT_KEEP_REPORTS}"
INPUT_KEEP_REPORTS=$((INPUT_KEEP_REPORTS + 1))
echo "if ${COUNT} > ${INPUT_KEEP_REPORTS}"
if ((COUNT > INPUT_KEEP_REPORTS)); then
	cd ./${INPUT_ALLURE_HISTORY} || exit 0
	echo "remove index.html last-history"
	rm index.html last-history -rv
	echo "remove old reports"
	ls | sort -n | head -n -$((${INPUT_KEEP_REPORTS} - 2)) | xargs rm -rv
	cd ${GITHUB_WORKSPACE} || exit 0
fi

cat >./${INPUT_ALLURE_HISTORY}/index.html <<EOF
<!DOCTYPE html><meta charset="utf-8"><meta http-equiv="refresh" content="0; URL=${GITHUB_PAGES_WEBSITE_URL}/${INPUT_GITHUB_RUN_NUM}">
<meta http-equiv="Pragma" content="no-cache"><meta http-equiv="Expires" content="0">
EOF

cat >./executor.json <<EOF
{"name":"GitHub Actions","type":"github","reportName":"Allure Report with history",
"url":"${GITHUB_PAGES_WEBSITE_URL}",
"reportUrl":"${GITHUB_PAGES_WEBSITE_URL}/${INPUT_GITHUB_RUN_NUM}/",
"buildUrl":"https://github.com/${INPUT_GITHUB_REPO}/actions/runs/${INPUT_GITHUB_RUN_ID}",
"buildName":"GitHub Actions Run #${INPUT_GITHUB_RUN_ID}","buildOrder":"${INPUT_GITHUB_RUN_NUM}"}
EOF

mv ./executor.json ./${INPUT_ALLURE_RESULTS}

echo "Codex=${INPUT_IMAGE_VERSION}" >>./${INPUT_ALLURE_RESULTS}/environment.properties
echo "DUT=${INPUT_DUT}" >>./${INPUT_ALLURE_RESULTS}/environment.properties

echo "keep allure history from ${INPUT_GH_PAGES}/last-history to ${INPUT_ALLURE_RESULTS}/history"
cp -r ./${INPUT_GH_PAGES}/last-history/. ./${INPUT_ALLURE_RESULTS}/history

echo "generating report from ${INPUT_ALLURE_RESULTS} to ${INPUT_ALLURE_REPORT} ..."
allure generate --clean ${INPUT_ALLURE_RESULTS} -o ${INPUT_ALLURE_REPORT}

echo "copy allure-report to ${INPUT_ALLURE_HISTORY}/${INPUT_GITHUB_RUN_NUM}"
cp -r ./${INPUT_ALLURE_REPORT}/. ./${INPUT_ALLURE_HISTORY}/${INPUT_GITHUB_RUN_NUM}
echo "copy allure-report history to /${INPUT_ALLURE_HISTORY}/last-history"
cp -r ./${INPUT_ALLURE_REPORT}/history/. ./${INPUT_ALLURE_HISTORY}/last-history
