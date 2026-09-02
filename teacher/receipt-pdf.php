<?php
declare(strict_types=1);require_once dirname(__DIR__).'/includes/auth.php';require_once dirname(__DIR__).'/services/pdf_exports.php';$current=tuman_require_role('TEACHER');$id=filter_var($_GET['id']??null,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);if(!$id){http_response_code(404);exit('Receipt unavailable.');}tuman_stream_receipt_pdf(tuman_database(),$current['id'],(int)$id);
