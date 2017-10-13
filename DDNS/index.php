<html>
<body>
<!-- web page for saving IP address and display last saving address-->
<?php
if ( !function_exists('sys_get_temp_dir')) {
  function sys_get_temp_dir() {
    if (!empty($_ENV['TMP'])) { return realpath($_ENV['TMP']); }
    if (!empty($_ENV['TMPDIR'])) { return realpath( $_ENV['TMPDIR']); }
    if (!empty($_ENV['TEMP'])) { return realpath( $_ENV['TEMP']); }
    $tempfile=tempnam(uniqid(rand(),TRUE),'');
    if (file_exists($tempfile)) {
    unlink($tempfile);
    return realpath(dirname($tempfile));
    }
  }
}
?>

<?php 
//echo "QUERY_STRING: " . $_SERVER['QUERY_STRING'];
//echo "<br>";
//$temp_file = tempnam(sys_get_temp_dir(), 'Tux');
//$temp_file = sys_get_temp_dir() . 'ip97845';
//$temp_file = '/dev/shm/ip97845';//seems to be frequently erased by cloud host.
$temp_file = 'ip97845';
//if has param of n,then save ip to file
if(isset($_GET['n'])){
    $n = $_GET['n'];
    if(isset($_GET['k'])){
        $key = $_GET['k'];//for simple security
        if($key == 'password'){
            $myfile = fopen($temp_file, "w") or die("Unable to open file!");
            for ($x=0; $x<$n; $x++) {
                $ip_idx = 'ip' . $x;
                $line = $ip_idx . "=$_GET[$ip_idx]<br>";
                echo $line;
                fwrite($myfile, $line);
            }
            fclose($myfile);
            echo 'save ip ok!<br>' ;
        }else echo 'key error';
    }else echo 'no key error';
    
}else{ // read from file
    $myfile = fopen($temp_file, "r") or die("Unable to open file!");
    echo fread($myfile,filesize($temp_file));
    fclose($myfile);
}


echo "<br><br>";
echo "Your INFO:<br>";
echo "IP: " . $_SERVER['REMOTE_ADDR'];
echo "<br>";
echo "UA: " . $_SERVER['HTTP_USER_AGENT'];
echo "<br>";

?>

</body>
</html>