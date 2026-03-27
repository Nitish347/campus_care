import os, re

screens_dir = r"d:\campus_care\campus_care\lib\screens\admin"

mapping = {
    'add_class_screen.dart': {'icon': 'Icons.class_', 'subtitle': 'Manage class details', 'breadcrumb': 'Classes'},
    'add_edit_subject_screen.dart': {'icon': 'Icons.book', 'subtitle': 'Manage subject details', 'breadcrumb': 'Subjects'},
    'add_timetable_screen.dart': {'icon': 'Icons.schedule', 'subtitle': 'Manage class timetable', 'breadcrumb': 'Timetable'},
    'timetable_screen.dart': {'icon': 'Icons.calendar_month', 'subtitle': 'View class schedules', 'breadcrumb': 'Timetable'},
    'admin_list_screen.dart': {'icon': 'Icons.admin_panel_settings', 'subtitle': 'Manage system administrators', 'breadcrumb': 'Admins'},
    'admin_attendance_screen.dart': {'icon': 'Icons.how_to_reg', 'subtitle': 'Track daily attendance', 'breadcrumb': 'Attendance'},
    'notice_management_screen.dart': {'icon': 'Icons.campaign', 'subtitle': 'Broadcast announcements', 'breadcrumb': 'Notices'},
    'admin_add_edit_exam_screen.dart': {'icon': 'Icons.assignment', 'subtitle': 'Configure examination details', 'breadcrumb': 'Exams'},
    'admin_add_edit_exam_type_screen.dart': {'icon': 'Icons.category', 'subtitle': 'Manage exam types', 'breadcrumb': 'Exam Types'},
    'admin_exam_timetable_screen.dart': {'icon': 'Icons.event_note', 'subtitle': 'Schedule examination dates', 'breadcrumb': 'Exam Schedule'},
    'admin_exam_type_screen.dart': {'icon': 'Icons.format_list_bulleted', 'subtitle': 'View examination categories', 'breadcrumb': 'Exam Types'},
    'exam_scheduler_screen.dart': {'icon': 'Icons.calendar_today', 'subtitle': 'Plan examination dates', 'breadcrumb': 'Exams'},
    'fee_management_screen.dart': {'icon': 'Icons.payments', 'subtitle': 'Track student fee collections', 'breadcrumb': 'Fees'},
    'admin_add_edit_homework_screen.dart': {'icon': 'Icons.home_work', 'subtitle': 'Create and manage assignments', 'breadcrumb': 'Homework'},
    'admin_homework_management_screen.dart': {'icon': 'Icons.assignment_turned_in', 'subtitle': 'Monitor student homework', 'breadcrumb': 'Homework'},
    'admin_lunch_management_screen.dart': {'icon': 'Icons.restaurant', 'subtitle': 'Manage cafeteria meal plans', 'breadcrumb': 'Lunch'},
    'add_medical_record_screen.dart': {'icon': 'Icons.medical_services', 'subtitle': 'Update student health records', 'breadcrumb': 'Medical'},
    'medical_dashboard_screen.dart': {'icon': 'Icons.health_and_safety', 'subtitle': 'Clinic health overview', 'breadcrumb': 'Medical'},
    'change_password_screen.dart': {'icon': 'Icons.password', 'subtitle': 'Update your security credentials', 'breadcrumb': 'Security'},
    'settings_screen.dart': {'icon': 'Icons.settings', 'subtitle': 'Application preferences', 'breadcrumb': 'Settings'},
    'teacher_details_screen.dart': {'icon': 'Icons.person', 'subtitle': 'View teacher profile details', 'breadcrumb': 'Teachers'}
}

for root, dirs, files in os.walk(screens_dir):
    for file in files:
        if file in mapping:
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            data = mapping[file]
            injection = f"subtitle: '{data['subtitle']}',\n        icon: {data['icon']},\n        showBreadcrumb: true,\n        breadcrumbLabel: '{data['breadcrumb']}',"
            
            # Check if this exact file already got enriched (e.g. earlier script successfully hit it)
            header_match = re.search(r'appBar:\s*(?:const\s+)?AdminPageHeader\((.*?)\)', content, re.DOTALL)
            if header_match:
                header_content = header_match.group(1)
                # If 'breadcrumbLabel' is already in the AdminPageHeader, we skip it.
                if 'breadcrumbLabel:' not in header_content:
                    # Inject right after 'AdminPageHeader('
                    content = content[:header_match.start()] + \
                              re.sub(
                                  r'(appBar:\s*(?:const\s+)?AdminPageHeader\()',
                                  rf'\1\n        {injection}',
                                  content[header_match.start():header_match.end()]
                              ) + \
                              content[header_match.end():]
                    
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"Injected rich properties to {file}")
