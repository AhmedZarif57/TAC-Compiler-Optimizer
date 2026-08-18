<?php

header("Content-Type: application/json");

if ($_SERVER["REQUEST_METHOD"] !== "POST")
{
    echo json_encode([
        "success" => false,
        "error" => "Invalid request."
    ]);

    exit;
}

$statement = $_POST["statement"] ?? "";

$statement = trim($statement);

if ($statement === "")
{
    echo json_encode([
        "success" => false,
        "error" => "Statement cannot be empty."
    ]);

    exit;
}

$command = "echo " . escapeshellarg($statement) .
           " | " . escapeshellarg(__DIR__ . "/parser") .
           " 2>&1";

$output = shell_exec($command);

if ($output === null)
{
    echo json_encode([
        "success" => false,
        "error" => "Compiler could not be executed."
    ]);

    exit;
}

$tac = "";
$optimized = "";

if (preg_match(
    '/===== THREE ADDRESS CODE =====\s*(.*?)\s*==============================/s',
    $output,
    $matches
))
{
    $tac = trim($matches[1]);
}

if (preg_match(
    '/===== OPTIMIZED THREE ADDRESS CODE =====\s*(.*?)\s*========================================/s',
    $output,
    $matches
))
{
    $optimized = trim($matches[1]);
}

if ($tac === "" || $optimized === "")
{
    echo json_encode([
        "success" => false,
        "error" => "Invalid statement or compiler error."
    ]);

    exit;
}

echo json_encode([
    "success" => true,
    "tac" => $tac,
    "optimized" => $optimized
]);

?>
