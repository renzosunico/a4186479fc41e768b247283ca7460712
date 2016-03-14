sleep 100&
sleep 50&
sleep 60&

echo "PS";
ps;

echo "JOBS";
jobs -pr;

jobs=`jobs -pr`;
while read -r job; do
    echo "Killing process $job";
    kill -9 $job;
done <<< "$jobs";