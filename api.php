<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST");

$server   = "localhost";
$userName = "root";
$pass     = "";
$db       = "FINAL_PROJECT_TEST";

$con = mysqli_connect($server, $userName, $pass, $db);

if (mysqli_connect_errno()) {
    echo json_encode(["status" => "error", "message" => "Failed to connect to MySQL: " . mysqli_connect_error()]);
    exit();
}

// Auto-create cancellation table if missing
$createNoticeTable = "CREATE TABLE IF NOT EXISTS Cancellation_Notices (
    notice_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE
)";
mysqli_query($con, $createNoticeTable);

$action = $_GET['action'] ?? '';

// 1. GET ALL STUDENTS & INSTRUCTOR PRIVILEGE FLAG
if ($action === 'get_students') {
    $query = "SELECT s.student_id, s.first_name, s.last_name, 
              CASE WHEN i.instructor_student_id IS NOT NULL THEN 1 ELSE 0 END AS is_instructor
              FROM Student s
              LEFT JOIN Instructor i ON s.student_id = i.instructor_student_id
              ORDER BY s.last_name, s.first_name";
    $result = mysqli_query($con, $query);
    $students = mysqli_fetch_all($result, MYSQLI_ASSOC);
    echo json_encode($students);
    exit();
}

// 2. GET ALL INSTRUCTORS
if ($action === 'get_instructors') {
    $query = "SELECT i.instructor_student_id, s.first_name, s.last_name, i.instructor_status 
              FROM Instructor i
              JOIN Student s ON i.instructor_student_id = s.student_id
              ORDER BY s.last_name, s.first_name";
    $result = mysqli_query($con, $query);
    $instructors = mysqli_fetch_all($result, MYSQLI_ASSOC);
    echo json_encode($instructors);
    exit();
}

// 3. GET STUDENT RANK HISTORY
if ($action === 'get_student_ranks') {
    $student_id = intval($_GET['student_id'] ?? 0);
    $query = "SELECT r.rank_name, r.belt_color, sr.date_awarded 
              FROM Student_Rank sr 
              JOIN `Rank` r ON sr.rank_id = r.rank_id 
              WHERE sr.student_id = $student_id 
              ORDER BY sr.date_awarded DESC";
    $result = mysqli_query($con, $query);
    $ranks = mysqli_fetch_all($result, MYSQLI_ASSOC);
    echo json_encode($ranks);
    exit();
}

// 4. GET ALL RANKS
if ($action === 'get_ranks') {
    $query = "SELECT rank_id, rank_name, belt_color FROM `Rank` ORDER BY rank_id ASC";
    $result = mysqli_query($con, $query);
    $ranks = mysqli_fetch_all($result, MYSQLI_ASSOC);
    echo json_encode($ranks);
    exit();
}

// 5. GET ALL CLASSES
if ($action === 'get_classes') {
    $query = "SELECT c.class_id, c.skill_level, c.day_of_week, c.start_time, c.room, c.instructor_student_id,
                     CONCAT(s.first_name, ' ', s.last_name) AS head_instructor_name
              FROM Class c 
              LEFT JOIN Student s ON c.instructor_student_id = s.student_id
              ORDER BY c.class_id ASC";
    $result = mysqli_query($con, $query);
    $classes = mysqli_fetch_all($result, MYSQLI_ASSOC);
    echo json_encode($classes);
    exit();
}

// 6. GET ALL MEETINGS (WITH HEAD AND ASSISTANT INSTRUCTORS)
if ($action === 'get_meetings') {
    $query = "SELECT cm.class_meeting_id, cm.meeting_date, c.class_id, c.skill_level, c.start_time, c.room,
              head_s.student_id AS head_id, CONCAT(head_s.first_name, ' ', head_s.last_name) AS head_name,
              GROUP_CONCAT(DISTINCT asst_s.student_id) AS assistant_ids,
              GROUP_CONCAT(DISTINCT CONCAT(asst_s.first_name, ' ', asst_s.last_name) SEPARATOR ', ') AS assistant_names
              FROM Class_Meeting cm
              JOIN Class c ON cm.class_id = c.class_id
              LEFT JOIN Class_Meeting_Instructor head_cmi ON cm.class_meeting_id = head_cmi.class_meeting_id AND head_cmi.role = 'Head Instructor'
              LEFT JOIN Student head_s ON head_cmi.instructor_student_id = head_s.student_id
              LEFT JOIN Class_Meeting_Instructor asst_cmi ON cm.class_meeting_id = asst_cmi.class_meeting_id AND asst_cmi.role = 'Assistant Instructor'
              LEFT JOIN Student asst_s ON asst_cmi.instructor_student_id = asst_s.student_id
              GROUP BY cm.class_meeting_id, cm.meeting_date, c.class_id, c.skill_level, c.start_time, c.room, head_s.student_id, head_s.first_name, head_s.last_name
              ORDER BY cm.meeting_date DESC";
    $result = mysqli_query($con, $query);
    $meetings = mysqli_fetch_all($result, MYSQLI_ASSOC);
    echo json_encode($meetings);
    exit();
}

// 7. GET LATEST RANKS FOR ROSTER
if ($action === 'get_roster_ranks') {
    $query = "SELECT sr.student_id, r.rank_name, r.belt_color
              FROM Student_Rank sr
              JOIN `Rank` r ON sr.rank_id = r.rank_id
              WHERE sr.student_rank_id IN (
                  SELECT MAX(student_rank_id) FROM Student_Rank GROUP BY student_id
              )";
    $result = mysqli_query($con, $query);
    $ranks = mysqli_fetch_all($result, MYSQLI_ASSOC);
    echo json_encode($ranks);
    exit();
}

// 8. INSPECT INSTRUCTOR IMPACT (PREVIEW FOR FIRE OR DELETE)
if ($action === 'inspect_instructor_impact') {
    $inst_id = intval($_GET['instructor_student_id'] ?? 0);
    
    // Impacted Assistant Meetings
    $asst_query = "SELECT cm.class_meeting_id, cm.meeting_date, c.skill_level 
                  FROM Class_Meeting_Instructor cmi
                  JOIN Class_Meeting cm ON cmi.class_meeting_id = cm.class_meeting_id
                  JOIN Class c ON cm.class_id = c.class_id
                  WHERE cmi.instructor_student_id = $inst_id AND cmi.role = 'Assistant Instructor'";
    $asst_res = mysqli_query($con, $asst_query);
    $asst_meetings = mysqli_fetch_all($asst_res, MYSQLI_ASSOC);

    // Classes where Head Instructor
    $head_query = "SELECT class_id, skill_level, day_of_week, start_time FROM Class WHERE instructor_student_id = $inst_id";
    $head_res = mysqli_query($con, $head_query);
    $head_classes = mysqli_fetch_all($head_res, MYSQLI_ASSOC);

    echo json_encode([
        "assistant_meetings" => $asst_meetings,
        "head_classes" => $head_classes
    ]);
    exit();
}

// 9. EXECUTE ADMIN INSTRUCTOR ACTION (FIRE OR DELETE)
if ($action === 'execute_instructor_action' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $inst_id = intval($_POST['instructor_student_id']);
    $action_type = $_POST['action_type']; // 'fire' or 'delete'
    $reassignments = json_decode($_POST['reassignments'] ?? '{}', true);

    mysqli_begin_transaction($con);

    try {
        // 1. Clean up ALL Assistant Instructor assignments for the target instructor first
        mysqli_query($con, "DELETE FROM Class_Meeting_Instructor WHERE instructor_student_id = $inst_id");

        // 2. Process Head Classes reassignment/cancellation
        foreach ($reassignments as $class_id => $decision) {
            $class_id = intval($class_id);

            if ($decision === 'cancel') {
                $c_info = mysqli_fetch_assoc(mysqli_query($con, "SELECT skill_level FROM Class WHERE class_id = $class_id"));
                $c_name = $c_info['skill_level'] ?? 'Class';

                $students_q = mysqli_query($con, "SELECT DISTINCT student_id FROM Attendance WHERE class_meeting_id IN (SELECT class_meeting_id FROM Class_Meeting WHERE class_id = $class_id)");
                while ($st = mysqli_fetch_assoc($students_q)) {
                    $sid = intval($st['student_id']);
                    $msg = mysqli_real_escape_string($con, "Notice: The class '$c_name' has been canceled due to instructor availability changes.");
                    mysqli_query($con, "INSERT INTO Cancellation_Notices (student_id, message) VALUES ($sid, '$msg')");
                }

                mysqli_query($con, "DELETE FROM Class_Meeting_Instructor WHERE class_meeting_id IN (SELECT class_meeting_id FROM Class_Meeting WHERE class_id = $class_id)");
                mysqli_query($con, "DELETE FROM Attendance WHERE class_meeting_id IN (SELECT class_meeting_id FROM Class_Meeting WHERE class_id = $class_id)");
                mysqli_query($con, "DELETE FROM Class_Meeting WHERE class_id = $class_id");
                mysqli_query($con, "DELETE FROM Class WHERE class_id = $class_id");
            } else {
                $new_inst_id = intval($decision);
                
                // Update Base Class Head Instructor
                mysqli_query($con, "UPDATE Class SET instructor_student_id = $new_inst_id WHERE class_id = $class_id");

                // Clear any existing assistant assignments for the new head instructor in these meetings
                // to avoid duplicate key issues on (class_meeting_id, instructor_student_id)
                mysqli_query($con, "DELETE FROM Class_Meeting_Instructor 
                                    WHERE instructor_student_id = $new_inst_id 
                                    AND class_meeting_id IN (SELECT class_meeting_id FROM Class_Meeting WHERE class_id = $class_id)");

                // Reassign Head Instructor in meetings
                mysqli_query($con, "UPDATE Class_Meeting_Instructor cmi 
                                    JOIN Class_Meeting cm ON cmi.class_meeting_id = cm.class_meeting_id 
                                    SET cmi.instructor_student_id = $new_inst_id 
                                    WHERE cm.class_id = $class_id AND cmi.role = 'Head Instructor'");
            }
        }

        // 3. Remove Instructor Record
        mysqli_query($con, "DELETE FROM Instructor WHERE instructor_student_id = $inst_id");

        if ($action_type === 'delete') {
            // Delete Student Profile entirely
            mysqli_query($con, "DELETE FROM Student_Rank WHERE student_id = $inst_id");
            mysqli_query($con, "DELETE FROM Attendance WHERE student_id = $inst_id");
            mysqli_query($con, "DELETE FROM Student WHERE student_id = $inst_id");
        }

        mysqli_commit($con);
        echo json_encode(["status" => "success", "message" => "Action processed successfully!"]);
    } catch (Exception $e) {
        mysqli_rollback($con);
        echo json_encode(["status" => "error", "message" => "Transaction failed: " . $e->getMessage()]);
    }
    exit();
}

// 10. GET & CLEAR CANCELLATION NOTICES
if ($action === 'get_notices') {
    $student_id = intval($_GET['student_id'] ?? 0);
    $res = mysqli_query($con, "SELECT notice_id, message FROM Cancellation_Notices WHERE student_id = $student_id");
    $notices = mysqli_fetch_all($res, MYSQLI_ASSOC);
    if (!empty($notices)) {
        mysqli_query($con, "DELETE FROM Cancellation_Notices WHERE student_id = $student_id");
    }
    echo json_encode($notices);
    exit();
}

// 11. ADD NEW STUDENT
if ($action === 'add_student' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $first_name = mysqli_real_escape_string($con, $_POST['first_name']);
    $last_name  = mysqli_real_escape_string($con, $_POST['last_name']);
    $dob        = mysqli_real_escape_string($con, $_POST['date_of_birth']);
    $join_date  = mysqli_real_escape_string($con, $_POST['join_date']);

    $query = "INSERT INTO Student (first_name, last_name, date_of_birth, join_date) 
              VALUES ('$first_name', '$last_name', '$dob', '$join_date')";

    if (mysqli_query($con, $query)) {
        $student_id = mysqli_insert_id($con);
        mysqli_query($con, "INSERT INTO Student_Rank (student_id, rank_id, date_awarded) VALUES ($student_id, 1, '$join_date')");
        echo json_encode(["status" => "success", "message" => "Student registered successfully!"]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
    }
    exit();
}

// 12. DELETE NON-INSTRUCTOR STUDENT
if ($action === 'delete_student' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $student_id = intval($_POST['student_id']);
    $query = "DELETE FROM Student WHERE student_id = $student_id";

    if (mysqli_query($con, $query)) {
        echo json_encode(["status" => "success", "message" => "Student deleted successfully!"]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
    }
    exit();
}

// 13. PROMOTE TO INSTRUCTOR
if ($action === 'promote_instructor' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $student_id = intval($_POST['student_id']);
    $start_date = mysqli_real_escape_string($con, $_POST['instructor_start_date']);
    $status     = mysqli_real_escape_string($con, $_POST['instructor_status']);

    $query = "INSERT INTO Instructor (instructor_student_id, instructor_start_date, instructor_status) 
              VALUES ($student_id, '$start_date', '$status')
              ON DUPLICATE KEY UPDATE instructor_status='$status', instructor_start_date='$start_date'";

    if (mysqli_query($con, $query)) {
        echo json_encode(["status" => "success", "message" => "Student promoted to instructor!"]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
    }
    exit();
}

// 14. AWARD RANK
if ($action === 'award_rank' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $student_id   = intval($_POST['student_id']);
    $rank_id      = intval($_POST['rank_id']);
    $date_awarded = mysqli_real_escape_string($con, $_POST['date_awarded']);

    $query = "INSERT INTO Student_Rank (student_id, rank_id, date_awarded) 
              VALUES ($student_id, $rank_id, '$date_awarded')";

    if (mysqli_query($con, $query)) {
        echo json_encode(["status" => "success", "message" => "Rank successfully awarded!"]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
    }
    exit();
}

// 15. CREATE BASE CLASS
if ($action === 'create_class' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $skill_level = mysqli_real_escape_string($con, $_POST['skill_level']);
    $day_of_week = mysqli_real_escape_string($con, $_POST['day_of_week']);
    $start_time  = mysqli_real_escape_string($con, $_POST['start_time']);
    $room        = mysqli_real_escape_string($con, $_POST['room']);
    $inst_id     = intval($_POST['instructor_student_id']);

    $query = "INSERT INTO Class (instructor_student_id, skill_level, day_of_week, start_time, room) 
              VALUES ($inst_id, '$skill_level', '$day_of_week', '$start_time', '$room')";

    if (mysqli_query($con, $query)) {
        echo json_encode(["status" => "success", "message" => "Class created successfully!"]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
    }
    exit();
}

// 16. CREATE MEETING
if ($action === 'create_meeting' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $class_id     = intval($_POST['class_id']);
    $date         = mysqli_real_escape_string($con, $_POST['meeting_date']);
    $head_inst_id = intval($_POST['head_instructor_id']);

    $query = "INSERT INTO Class_Meeting (class_id, meeting_date) VALUES ($class_id, '$date')";

    if (!mysqli_query($con, $query)) {
        echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
        exit();
    }

    $meeting_id = mysqli_insert_id($con);
    $inst_query = "INSERT INTO Class_Meeting_Instructor (class_meeting_id, instructor_student_id, role) 
                   VALUES ($meeting_id, $head_inst_id, 'Head Instructor')";

    if (!mysqli_query($con, $inst_query)) {
        echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
        exit();
    }

    echo json_encode(["status" => "success", "message" => "Class meeting scheduled successfully!", "meeting_id" => $meeting_id]);
    exit();
}

// 17. STUDENT CHECK-IN
if ($action === 'checkin_student' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $student_id = intval($_POST['student_id']);
    $meeting_id = intval($_POST['class_meeting_id']);

    $query = "INSERT INTO Attendance (student_id, class_meeting_id) VALUES ($student_id, $meeting_id)";

    if (mysqli_query($con, $query)) {
        echo json_encode(["status" => "success", "message" => "Check-in successful!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Already checked in or DB error: " . mysqli_error($con)]);
    }
    exit();
}

// 18. ASSIGN ASSISTANT INSTRUCTOR
if ($action === 'assign_assistant' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $meeting_id = intval($_POST['class_meeting_id']);
    $inst_id    = intval($_POST['instructor_student_id']);

    $query = "INSERT INTO Class_Meeting_Instructor (class_meeting_id, instructor_student_id, role) 
              VALUES ($meeting_id, $inst_id, 'Assistant Instructor')
              ON DUPLICATE KEY UPDATE role='Assistant Instructor'";

    if (mysqli_query($con, $query)) {
        echo json_encode(["status" => "success", "message" => "Signed up as Assistant Instructor!"]);
    } else {
        echo json_encode(["status" => "error", "message" => mysqli_error($con)]);
    }
    exit();
}

mysqli_close($con);
?>