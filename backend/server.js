const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

let users = [
  {
    uid: 'lecturer-demo',
    id: 'lecturer-demo',
    email: 'lecturer@demo.com',
    name: 'Demo Lecturer',
    role: 'lecturer',
    department: 'Information Technology'
  },
  {
    uid: 'student-demo',
    id: 'student-demo',
    email: 'student@demo.com',
    name: 'Demo Student',
    role: 'student',
    program: 'Bachelor of IT',
    year: 1
  }
];

let units = [
  {
    id: 'unit-ict101',
    code: 'ICT101',
    name: 'Introduction to Information Technology',
    description: 'Foundational concepts in computing, systems, and applications.',
    credits: 10,
    semester: '2026-S1',
    maxStudents: 40,
    lecturerId: 'lecturer-demo',
    lecturerName: 'Demo Lecturer'
  },
  {
    id: 'unit-ict201',
    code: 'ICT201',
    name: 'Database Systems',
    description: 'Relational database design, SQL, keys, relationships, and normalisation.',
    credits: 10,
    semester: '2026-S1',
    maxStudents: 35,
    lecturerId: 'lecturer-demo',
    lecturerName: 'Demo Lecturer'
  },
  {
    id: 'unit-ict313',
    code: 'ICT313',
    name: 'Big Data',
    description: 'Big data processing concepts, Hadoop, MapReduce, and analytics.',
    credits: 10,
    semester: '2026-S2',
    maxStudents: 30,
    lecturerId: 'lecturer-demo',
    lecturerName: 'Demo Lecturer'
  }
];

let enrollments = [
  {
    id: 'enrol-1',
    studentId: 'student-demo',
    unitId: 'unit-ict101',
    status: 'active',
    enrolledAt: new Date().toISOString()
  }
];

let tasks = [];
let notifications = [];
let studySessions = [];

function nextId(prefix) {
  return `${prefix}-${Date.now()}-${Math.floor(Math.random() * 100000)}`;
}

function getLecturerName(lecturerId) {
  const lecturer = users.find((user) => user.uid === lecturerId || user.id === lecturerId);
  return lecturer ? lecturer.name : '';
}

function withLecturer(unit) {
  return {
    ...unit,
    lecturerName: unit.lecturerName || getLecturerName(unit.lecturerId),
    lecturer: users.find((user) => user.uid === unit.lecturerId || user.id === unit.lecturerId) || null
  };
}

function findUnit(unitId) {
  return units.find((unit) => unit.id === unitId || unit.code === unitId);
}

function notFound(res, message) {
  return res.status(404).json({ error: message });
}

function studentHasActiveEnrollment(studentId, unitId) {
  const unit = findUnit(unitId);
  if (!unit) return false;
  return enrollments.some((item) =>
    item.studentId === studentId && item.unitId === unit.id && item.status === 'active'
  );
}

function taskVisibleToStudent(task, studentId) {
  if (task.assignedToId === studentId || task.userId === studentId) return true;
  if (Array.isArray(task.assignedToIds) && task.assignedToIds.includes(studentId)) return true;
  if (task.unitId && !task.assignedToId && studentHasActiveEnrollment(studentId, task.unitId)) return true;
  return false;
}

app.get('/', (req, res) => {
  res.json({ message: 'STM backend is running', api: '/api' });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', port: PORT });
});

app.post('/api/users/create', (req, res) => {
  const { uid, email, name, role } = req.body;
  if (!uid || !email) {
    return res.status(400).json({ error: 'uid and email are required' });
  }

  let user = users.find((item) => item.uid === uid);
  if (user) {
    user.email = email;
    user.name = name || user.name || email.split('@')[0];
    user.role = role || user.role || 'student';
  } else {
    user = {
      uid,
      id: uid,
      email,
      name: name || email.split('@')[0],
      role: role || 'student'
    };
    users.push(user);
  }

  res.status(200).json({ user });
});

app.get('/api/users', (req, res) => {
  const { role } = req.query;
  const filteredUsers = role ? users.filter((user) => user.role === role) : users;
  res.json({ users: filteredUsers });
});

app.get('/api/users/:uid', (req, res) => {
  const user = users.find((item) => item.uid === req.params.uid || item.id === req.params.uid);
  if (!user) return notFound(res, 'User not found');
  res.json({ user });
});

app.put('/api/users/:uid/profile', (req, res) => {
  const user = users.find((item) => item.uid === req.params.uid || item.id === req.params.uid);
  if (!user) return notFound(res, 'User not found');
  Object.assign(user, req.body);
  res.json({ user });
});

app.put('/api/users/:uid/role', (req, res) => {
  const user = users.find((item) => item.uid === req.params.uid || item.id === req.params.uid);
  if (!user) return notFound(res, 'User not found');
  user.role = req.body.role || user.role;
  res.json({ user });
});

app.delete('/api/users/:uid', (req, res) => {
  const before = users.length;
  users = users.filter((item) => item.uid !== req.params.uid && item.id !== req.params.uid);
  enrollments = enrollments.filter((item) => item.studentId !== req.params.uid);
  res.json({ deleted: before !== users.length });
});

app.get('/api/units', (req, res) => {
  const { lecturerId } = req.query;
  const filteredUnits = lecturerId ? units.filter((unit) => unit.lecturerId === lecturerId) : units;
  res.json({ units: filteredUnits.map(withLecturer) });
});

app.get('/api/units/code/:code', (req, res) => {
  const unit = units.find((item) => item.code.toLowerCase() === req.params.code.toLowerCase());
  if (!unit) return notFound(res, 'Unit not found');
  res.json({ unit: withLecturer(unit) });
});

app.get('/api/units/:id', (req, res) => {
  const unit = findUnit(req.params.id);
  if (!unit) return notFound(res, 'Unit not found');
  res.json({ unit: withLecturer(unit) });
});

app.post('/api/units', (req, res) => {
  const { code, name, description, credits, semester, maxStudents, lecturerId } = req.body;
  if (!code || !name || !lecturerId) {
    return res.status(400).json({ error: 'code, name, and lecturerId are required' });
  }

  const existing = units.find((unit) => unit.code.toLowerCase() === code.toLowerCase());
  if (existing) {
    return res.status(409).json({ error: 'A unit with this code already exists' });
  }

  const unit = {
    id: nextId('unit'),
    code,
    name,
    description: description || '',
    credits: Number(credits) || 0,
    semester: semester || '',
    maxStudents: Number(maxStudents) || 30,
    lecturerId,
    lecturerName: getLecturerName(lecturerId)
  };

  units.push(unit);

  users
    .filter((user) => user.role === 'student')
    .forEach((student) => {
      notifications.push({
        id: nextId('notif'),
        userId: student.uid || student.id,
        title: 'New unit available',
        message: `${unit.code} — ${unit.name} is now available for enrolment.`,
        read: false,
        createdAt: new Date().toISOString(),
        unitId: unit.id
      });
    });

  res.status(200).json({ unit: withLecturer(unit) });
});

app.post('/api/units/:id/enroll', (req, res) => {
  const unit = findUnit(req.params.id);
  if (!unit) return notFound(res, 'Unit not found');

  const studentId = req.body.studentId;
  if (!studentId) return res.status(400).json({ error: 'studentId is required' });

  const existing = enrollments.find((item) => item.studentId === studentId && item.unitId === unit.id);
  if (existing) {
    return res.status(200).json({ enrollment: { ...existing, unit: withLecturer(unit) } });
  }

  const activeCount = enrollments.filter((item) => item.unitId === unit.id && item.status === 'active').length;
  if (activeCount >= unit.maxStudents) {
    return res.status(409).json({ error: 'Unit is full' });
  }

  const enrollment = {
    id: nextId('enrol'),
    studentId,
    unitId: unit.id,
    status: 'active',
    enrolledAt: new Date().toISOString()
  };

  enrollments.push(enrollment);
  res.status(201).json({ enrollment: { ...enrollment, unit: withLecturer(unit) } });
});

app.delete('/api/units/:id/enroll', (req, res) => {
  const unit = findUnit(req.params.id);
  if (!unit) return notFound(res, 'Unit not found');

  const studentId = req.body.studentId;
  if (!studentId) return res.status(400).json({ error: 'studentId is required' });

  const before = enrollments.length;
  enrollments = enrollments.filter((item) => !(item.studentId === studentId && item.unitId === unit.id));
  res.status(200).json({ dropped: before !== enrollments.length });
});

app.get('/api/students/:id/units', (req, res) => {
  const studentEnrollments = enrollments
    .filter((item) => item.studentId === req.params.id)
    .map((item) => ({
      ...item,
      unit: withLecturer(findUnit(item.unitId))
    }))
    .filter((item) => item.unit);

  res.json({
    enrollments: studentEnrollments,
    units: studentEnrollments.map((item) => item.unit)
  });
});

app.get('/api/enrollments/unit/:unitId', (req, res) => {
  const unit = findUnit(req.params.unitId);
  if (!unit) return notFound(res, 'Unit not found');

  const unitEnrollments = enrollments
    .filter((item) => item.unitId === unit.id)
    .map((item) => ({
      ...item,
      student: users.find((user) => user.uid === item.studentId || user.id === item.studentId) || null
    }));

  res.json({ enrollments: unitEnrollments });
});

app.post('/api/tasks', (req, res) => {
  const unit = req.body.unitId ? findUnit(req.body.unitId) : null;
  const assignedToIds = [];

  if (unit && !req.body.assignedToId) {
    enrollments
      .filter((item) => item.unitId === unit.id && item.status === 'active')
      .forEach((item) => {
        if (!assignedToIds.includes(item.studentId)) assignedToIds.push(item.studentId);
      });
  }

  const task = {
    id: nextId('task'),
    ...req.body,
    unitId: unit ? unit.id : (req.body.unitId || ''),
    unitCode: unit ? unit.code : req.body.unitCode,
    unitName: unit ? unit.name : req.body.unitName,
    assignedToIds,
    createdAt: new Date().toISOString()
  };

  tasks.push(task);

  assignedToIds.forEach((studentId) => {
    notifications.push({
      id: nextId('notif'),
      userId: studentId,
      title: 'New task assigned',
      message: `${task.title} has been added for ${task.unitCode || 'your unit'}.`,
      read: false,
      createdAt: new Date().toISOString(),
      taskId: task.id,
      unitId: task.unitId
    });
  });

  res.status(200).json({ task });
});

app.get('/api/tasks/user/:userId', (req, res) => {
  const filteredTasks = tasks.filter((task) => taskVisibleToStudent(task, req.params.userId));
  const statusTasks = req.query.status ? filteredTasks.filter((task) => task.status === req.query.status) : filteredTasks;
  res.json({ tasks: statusTasks });
});

app.get('/api/tasks/unit/:unitId', (req, res) => {
  let filteredTasks = tasks.filter((task) => task.unitId === req.params.unitId);
  if (req.query.assignedToId) {
    filteredTasks = filteredTasks.filter((task) => task.assignedToId === req.query.assignedToId);
  }
  res.json({ tasks: filteredTasks });
});

app.put('/api/tasks/:taskId/status', (req, res) => {
  const task = tasks.find((item) => item.id === req.params.taskId);
  if (!task) return notFound(res, 'Task not found');
  task.status = req.body.status || task.status;
  if (req.body.completedHours !== undefined) task.completedHours = req.body.completedHours;
  res.json({ task });
});

app.delete('/api/tasks/:taskId', (req, res) => {
  const before = tasks.length;
  tasks = tasks.filter((item) => item.id !== req.params.taskId);
  res.json({ deleted: before !== tasks.length });
});

app.get('/api/notifications/user/:userId', (req, res) => {
  let userNotifications = notifications.filter((item) => item.userId === req.params.userId);
  if (req.query.unreadOnly === 'true') {
    userNotifications = userNotifications.filter((item) => !item.read);
  }
  res.json({ notifications: userNotifications });
});

app.put('/api/notifications/:notificationId/read', (req, res) => {
  const notification = notifications.find((item) => item.id === req.params.notificationId);
  if (!notification) return notFound(res, 'Notification not found');
  notification.read = true;
  res.json({ notification });
});

app.put('/api/notifications/user/:userId/read-all', (req, res) => {
  notifications = notifications.map((item) => item.userId === req.params.userId ? { ...item, read: true } : item);
  res.json({ success: true });
});

app.post('/api/study-sessions', (req, res) => {
  const session = {
    id: nextId('study'),
    ...req.body,
    createdAt: new Date().toISOString()
  };
  studySessions.push(session);
  res.status(200).json({ session });
});

app.get('/api/study-sessions/total/:userId', (req, res) => {
  const totalSeconds = studySessions
    .filter((item) => item.userId === req.params.userId)
    .reduce((sum, item) => sum + (Number(item.durationSeconds) || 0), 0);
  res.json({ userId: req.params.userId, totalSeconds, totalMinutes: Math.round(totalSeconds / 60) });
});

app.get('/api/study-sessions/user/:userId', (req, res) => {
  let sessions = studySessions.filter((item) => item.userId === req.params.userId);
  if (req.query.limit) {
    sessions = sessions.slice(0, Number(req.query.limit));
  }
  res.json({ sessions });
});

app.get('/api/study-sessions/stats/:userId', (req, res) => {
  const sessions = studySessions.filter((item) => item.userId === req.params.userId);
  const totalSeconds = sessions.reduce((sum, item) => sum + (Number(item.durationSeconds) || 0), 0);
  res.json({
    userId: req.params.userId,
    totalSessions: sessions.length,
    totalSeconds,
    totalMinutes: Math.round(totalSeconds / 60)
  });
});

app.use((req, res) => {
  res.status(404).json({ error: `Route not found: ${req.method} ${req.originalUrl}` });
});

app.listen(PORT, () => {
  console.log(`STM backend running on http://localhost:${PORT}`);
  console.log(`API health check: http://localhost:${PORT}/api/health`);
});
