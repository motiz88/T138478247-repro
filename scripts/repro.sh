#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR/.."

echo -e '\n### Setup (yarn, Metro)\n'
mkdir -p build
rm build/*.log
yarn 2> build/yarn-err.log
PORT=8081
node_modules/.bin/metro serve --port $PORT > build/metro-1.log &
METRO=$!
sleep 1

echo -e '\n### Initial build\n'
cat > app/node_modules/@motiz88/test-dep/package.json <<-EOF
{
  "name": "@motiz88/test-dep",
  "main": "main1.js"
}
EOF
sleep 1
ENTRY_POINT=$(jq -r .main app/node_modules/@motiz88/test-dep/package.json)
echo "Expected: Hello from $ENTRY_POINT"
echo -n "Actual: "
curl "http://localhost:$PORT/app/index.bundle?platform=ios&dev=true&minify=false" --silent > build/bundle-1.js && node build/bundle-1


echo -e '\n### Build after changing package.json (same Metro instance)\n'
cat > app/node_modules/@motiz88/test-dep/package.json <<-EOF
{
  "name": "@motiz88/test-dep",
  "main": "main2.js"
}
EOF
sleep 1
ENTRY_POINT=$(jq -r .main app/node_modules/@motiz88/test-dep/package.json)
echo "Expected: Hello from $ENTRY_POINT"
echo -n "Actual: "
curl "http://localhost:$PORT/app/index.bundle?platform=ios&dev=true&minify=false" --silent > build/bundle-2.js && node build/bundle-2

kill -INT $METRO


echo -e '\n### Build after changing package.json (new Metro instance)\n'
node_modules/.bin/metro serve --port $PORT > build/metro-2.log &
METRO=$!
sleep 1
ENTRY_POINT=$(jq -r .main app/node_modules/@motiz88/test-dep/package.json)
echo "Expected: Hello from $ENTRY_POINT"
echo -n "Actual: "
curl "http://localhost:$PORT/app/index.bundle?platform=ios&dev=true&minify=false" --silent > build/bundle-3.js && node build/bundle-3
kill -INT $METRO
