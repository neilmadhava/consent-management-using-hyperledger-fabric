counter=7051;

for count in {1..10}
do
	let "counter = $counter + 1000";
	echo $counter;
done
