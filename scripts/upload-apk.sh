#!/bin/sh

git config --global user.name "Travis CI"
git config --global user.email "noreply+travis@fossasia.org"

bundle exec fastlane buildAAB

git clone --quiet --branch=apk https://fossasia:$GITHUB_KEY@github.com/fossasia/badge-magic-android apk > /dev/null
cd apk

if [[ $TRAVIS_BRANCH =~ ^(master)$ ]]; then
	rm -rf *
else
	rm -rf badge-magic-dev*
fi

find ../app/build/outputs -type f \( -name '*.apk' -o -name '*.aab' \) -exec cp -v {} . \;

for file in app*; do
    if [[ $file =~ ".aab" ]]; then
        mv $file badge-magic-$TRAVIS_BRANCH-$file
    else
        mv $file badge-magic-$TRAVIS_BRANCH-${file:4}
    fi
done

git checkout --orphan temporary

git add --all .
git commit -am "[Auto] Update Test Apk ($(date +%Y-%m-%d.%H:%M:%S))"

git branch -D apk
git branch -m apk

git push origin apk --force --quiet > /dev/null

if [[ $TRAVIS_BRANCH =~ ^(master)$ ]]; then
    cd ..
    bundle exec fastlane uploadToPlaystore
    exit 0
fi

echo "We publish apk only for changes in master branch. So, let's skip this shall we ? :)"