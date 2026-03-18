<?php
$connDB = pg_connect("host=localhost dbname=odidb user=postgres password=1234");
$connSQL = pg_connect("host=localhost dbname=odisql user=postgres password=1234");

if (!$connDB) {
    echo "<div style='color:red;'>Αποτυχία σύνδεσης στη βάση.</div>";
    exit;
}
if (!$connSQL) {
    echo "<div style='color:red;'>Αποτυχία σύνδεσης στη βάση.</div>";
    exit;
}

$message = "";
$tableOutput = "";

if (isset($_POST['run_sql_file'])) {
    $fileToRun = $_POST['run_sql_file'];
	if ($fileToRun === 'install.sql' || $fileToRun === 'load.sql') {
        $conn = $connDB;
    } else {
        $conn = $connSQL;
    }


	$path = __DIR__ . '/../sql/' . $fileToRun;
	if (file_exists($path)) {
		$sql = file_get_contents($path);

		if (!empty(trim($sql))) {
			@pg_query($conn, "SET client_min_messages TO NOTICE");
			$result = @pg_query($conn, $sql);
			if ($result) {
				if (pg_num_fields($result) > 0) {
					$tableOutput = "<table class='result-table'>";
					$tableOutput .= "<thead><tr>";
					for ($i = 0; $i < pg_num_fields($result); $i++) {
						$fieldName = pg_field_name($result, $i);
						$tableOutput .= "<th>{$fieldName}</th>";
					}
					$tableOutput .= "</tr></thead><tbody>";

					while ($row = pg_fetch_assoc($result)) {
						$tableOutput .= "<tr>";
						foreach ($row as $cell) {
							$tableOutput .= "<td>" . htmlspecialchars($cell) . "</td>";
						}
						$tableOutput .= "</tr>";
					}
					$tableOutput .= "</tbody></table>";

					$message = "<div class='success-message'>Το SELECT query εκτελέστηκε και επιστράφηκαν αποτελέσματα.</div>";
				} else {
					$message = "<div class='success-message'>Το query εκτελέστηκε επιτυχώς (χωρίς δεδομένα).</div>";
				}
			} else {
				$message = "<div class='error-message'>Σφάλμα: " . pg_last_error($conn) . "</div>";
			}
			/*$notice = pg_last_notice($conn);
			if ($notice) {
				$message .= "<div class='notice-message'>Debug: $notice</div>";
			}*/
			$notices = pg_last_notice($conn, PGSQL_NOTICE_ALL);  // PHP 8.1+
			if (!empty($notices)) {
				foreach ($notices as $notice) {
					if (!empty(trim($notice))) {
						$message .= "<div class='notice-message'>". $notice . "</div>";
					}
				}
			}
		} else {
			$message = "<div class='error-message'>Δεν δόθηκε query για εκτέλεση.</div>";
		}
	} else {
		$message = "<div style='color:red;'>Το αρχείο δεν βρέθηκε.</div>";
	}
}
?>

<!DOCTYPE html>
<html lang="el">
<head>
    <meta charset="UTF-8">
    <title>Εκτέλεση SQL</title>
	<style>
        body {
            font-family: Arial, sans-serif;
        }
        .container {
            width: 80%;
            margin: 0 auto;
        }
        textarea {
            width: 100%;
            height: 150px;
            margin-bottom: 10px;
        }
        .button_init {
            background-color: #4CAFFF;
            color: white;
            padding: 10px 20px;
            border: none;
            cursor: pointer;
        }
        .button_init:hover {
            background-color: #45A0FE;
        }
        .button_qry {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            cursor: pointer;
        }
        .button_qry:hover {
            background-color: #45A049;
        }
        .button_plan {
            background-color: #F006D0;
            color: white;
            padding: 10px 20px;
            border: none;
            cursor: pointer;
        }
        .button_plan:hover {
            background-color: #F006C0;
        }
        .button_check {
            background-color: #F0903A;
            color: white;
            padding: 10px 20px;
            border: none;
            cursor: pointer;
        }
        .button_check:hover {
            background-color: #F0902A;
        }
        input[type="file"] {
            margin: 10px 0;
        }
		.result-table {
			width: 100%;
			border-collapse: collapse;
			margin-top: 20px;
			background-color: #f9f9f9;
			box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
		}

		.result-table th, .result-table td {
			border: 1px solid #ddd;
			padding: 8px 12px;
			text-align: left;
		}

		.result-table th {
			background-color: #0018F7;
			color: white;
		}

		.result-table tr:nth-child(even) {
			background-color: #f2f2f2;
		}

		.result-table tr:hover {
			background-color: #ddd;
		}

		.success-message {
			color: #155724;
			background-color: #d4edda;
			border: 1px solid #c3e6cb;
			padding: 10px;
			margin-top: 15px;
			border-radius: 5px;
		}

		.error-message {
			color: #721c24;
			background-color: #f8d7da;
			border: 1px solid #f5c6cb;
			padding: 10px;
			margin-top: 15px;
			border-radius: 5px;
		}
    </style>
    <script>
        function confirmRun(fileName) {
			document.getElementById('sqlfile').value = fileName;
			document.getElementById('formRun').submit();
        }
    </script>
</head>
<body>

<h2>Επιλογή SQL Εντολής με Επιβεβαίωση:</h2>

<form method="post" id="formRun">
    <input type="hidden" name="run_sql_file" id="sqlfile" value="">
	<br></br>
	<br></br>
    <button type="button" class="button_init" onclick="confirmRun('install.sql')">Δημιουργία βάσης</button>
    <button type="button" class="button_init" onclick="confirmRun('load.sql')">Εισαγωγή δεδομένων</button>
	<br></br>
    <button type="button" class="button_qry" onclick="confirmRun('Q01.sql')">Εκτέλεση q1</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q02.sql')">Εκτέλεση q2</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q03.sql')">Εκτέλεση q3</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q05.sql')">Εκτέλεση q5</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q07.sql')">Εκτέλεση q7</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q08.sql')">Εκτέλεση q8</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q09.sql')">Εκτέλεση q9</button>
	<br></br>
    <button type="button" class="button_qry" onclick="confirmRun('Q10.sql')">Εκτέλεση q10</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q11.sql')">Εκτέλεση q11</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q12.sql')">Εκτέλεση q12</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q13.sql')">Εκτέλεση q13</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q14.sql')">Εκτέλεση q14</button>
    <button type="button" class="button_qry" onclick="confirmRun('Q15.sql')">Εκτέλεση q15</button>
	<br></br>
    <button type="button" class="button_plan" onclick="confirmRun('Q04.sql')">Εκτέλεση q4 για δεδομένα</button>
    <button type="button" class="button_plan" onclick="confirmRun('Q04_planA.sql')">Εκτέλεση q4 plan A</button>
    <button type="button" class="button_plan" onclick="confirmRun('Q04_planB.sql')">Εκτέλεση q4 plan B</button>
	<br></br>
    <button type="button" class="button_plan" onclick="confirmRun('Q06.sql')">Εκτέλεση q6 για δεδομένα</button>
    <button type="button" class="button_plan" onclick="confirmRun('Q06_planA.sql')">Εκτέλεση q6 plan A</button>
    <button type="button" class="button_plan" onclick="confirmRun('Q06_planB.sql')">Εκτέλεση q6 plan B</button>
	<br></br>
    <button type="button" class="button_check" onclick="confirmRun('activfestevent_fail.sql')">Ενεργοποίηση μη στελεχομένης παράστασης</button>
    <button type="button" class="button_check" onclick="confirmRun('activfestevent_ok.sql')">Ενεργοποίηση στελεχομένης παράστασης</button>
	<br></br>
    <button type="button" class="button_check" onclick="confirmRun('soldout_demo.sql')">Δημιουργία soldout παράστασης</button>
</form>

<?php
echo $message;
echo $tableOutput;
?>

</body>
</html>
