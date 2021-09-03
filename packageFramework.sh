if [ "$2" == "" ]
then 
echo dateZ and platform arguments
exit
fi

echo Building packages...
targetdir=target
mkdir $targetdir
java -Dant.home=utilities/ant -classpath utilities/saxon/saxon.jar:utilities/ant/lib/ant-launcher.jar:utilities/saxon9he/saxon9he.jar:. org.apache.tools.ant.launch.Launcher -buildfile packageFramework.xml -Ddir=$targetdir -Dversion=$1
serverReturn=$?

sleep 2
echo $serverReturn >$targetdir/build.exitcode.$1.txt

if [ "$targetdir" = "target" ]
then
if [ "$2" = "github" ]
then
if [ "$3" = "DELETE-REPOSITORY-FILES-AS-WELL" ] #secret undocumented failsafe
then
# further reduce GitHub storage costs by deleting repository files

find . -not -name target -not -name .github -maxdepth 1 -exec rm -r -f {} \;
mv $targetdir/frameworks $targetdir/build.exitcode.$1.txt $targetdir/build.console.$1.txt .
rm -r -f $targetdir

fi
fi
fi

exit 0 # always be successful so that github returns ZIP of results
