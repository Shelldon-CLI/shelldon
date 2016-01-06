FILENAME=$(ls *.gem)
MACHINE=opsadm01.vdl.e2nova
echo Sending $FILENAME to $MACHINE
scp $FILENAME $MACHINE:/tmp/
ssh $MACHINE "gem install /tmp/$FILENAME"
