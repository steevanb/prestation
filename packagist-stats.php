<?php

use Packagist\Api\Result\Result;
use Packagist\Api\Result\Package;

require('vendor/autoload.php');

$client = new Packagist\Api\Client();

$downloads = 0;
/** @var Result $repository */
foreach ($client->search('steevanb') as $repository) {
    $downloads += $repository->getDownloads();
    $repositories[] = $client->get($repository->getName());
}
usort($repositories, function(Package $repository1, Package $repository2) {
    return $repository1->getDownloads() < $repository2->getDownloads() ? 1 : -1;
});
?>
<!DOCTYPE HTML>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="author" content="Steevan BARBOYON" />
        <title>Statistiques GitHub</title>
        <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" rel="stylesheet">
        <link href="css/packagist-stats.css" rel="stylesheet">
        <link href="css/font-awesome.css" rel="stylesheet" type="text/css">
    </head>
    <body>
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default">
                    <div class="panel-body text-center" style="background-color: #DFF0D8">
                        <?php echo number_format(count($repositories), 0, ',', ' ') ?> dépôts,
                        <?php echo number_format($downloads, 0, ',', ' ') ?> téléchargements
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
            <?php
            /** @var Result $repository */
            foreach ($repositories as $repository) {
                ?>
                <div class="col-md-4">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <div class="row">
                                <div class="col-md-9">
                                    <h3 class="panel-title">
                                        <a href="<?=$repository->getRepository()?>" target="_blank"><?=$repository->getName()?></a>
                                    </h3>
                                </div>
                                <div class="col-md-3 text-right">
                                    <?php echo (new \DateTime($repository->getTime()))->format('d/m/Y') ?>
                                </div>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <span class="stat-left">
                                        <span class="fa fa-eye"></span> Watch
                                    </span>
                                    <span class="stat-right">
                                        <?=$repository->githubWatchers?>
                                    </span>
                                </div>
                                <div class="col-md-4 text-center">
                                    <span class="stat-left">
                                        <span class="fa fa-star"></span> Star
                                    </span>
                                    <span class="stat-right">
                                        <?=($repository->githubStars === null ? 0 : $repository->githubStars)?>
                                    </span>
                                </div>
                                <div class="col-md-4 text-right">
                                    <span class="stat-left">
                                        <span class="fa fa-code-fork"></span> Fork
                                    </span>
                                    <span class="stat-right">
                                        <?=$repository->githubForks?>
                                    </span>
                                </div>
                            </div>
                            <div class="row stats-separator">
                                <div class="col-md-4">
                                    <span class="stat-left">
                                        <span class="fa fa-download"></span> Today
                                    </span>
                                    <span class="stat-right">
                                        <?php echo number_format($repository->getDownloads()->getDaily(), 0, '.', ' ') ?>
                                    </span>
                                </div>
                                <div class="col-md-4 text-center">
                                    <span class="stat-left">
                                        <span class="fa fa-download"></span> 30 days
                                    </span>
                                    <span class="stat-right">
                                        <?php echo number_format($repository->getDownloads()->getMonthly(), 0, '.', ' ') ?>
                                    </span>
                                </div>
                                <div class="col-md-4 text-right">
                                    <span class="stat-left">
                                        <span class="fa fa-download"></span> Total
                                    </span>
                                    <span class="stat-right">
                                        <?php echo number_format($repository->getDownloads()->getTotal(), 0, '.', ' ') ?>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            <?php } ?>
        </div>
    </body>
</html>
