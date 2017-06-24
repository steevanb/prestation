<?php
try {
    require('vendor/autoload.php');

    $client = new Packagist\Api\Client();

    $downloads = [];
    $downloads = 0;
    $repositories = 0;
    /** @var Packagist\Api\Result\Result $result */
    foreach ($client->search('steevanb') as $result) {
        $repositories++;
        $downloads += $result->getDownloads();
    }
} catch (\Exception $e) {
    $downloads = null;
}
?>
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
		<title>GitHub</title>

		<!-- Bootstrap -->
		<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" rel="stylesheet">
        <link href="css/github.css" rel="stylesheet" />
		
		<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
		<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
		<!--[if lt IE 9]>
			<script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
			<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
		<![endif]-->
	</head>
	<body>
		<div
			data-toggle="github-widget"
			data-user="steevanb"
			data-title="<a href='https://github.com/steevanb' target='_blank'>github.com/steevanb</a> - <?=$repositories?> dépôts - <?php echo number_format($downloads, 0, ',', ' ') ?> téléchargements"
		></div>

		<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
		<!-- Include all compiled plugins (below), or include individual files as needed -->
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
		<script src="js/bootstrap-github-widget.min.js" type="text/javascript"></script>
	</body>
</html>
