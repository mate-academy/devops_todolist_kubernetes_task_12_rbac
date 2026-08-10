#!/usr/bin/env python
import os
import sys

if __name__ == "__main__":
    project_root = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, os.path.join(project_root, "src"))
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "todolist.settings")

    from django.core.management import execute_from_command_line

    execute_from_command_line(sys.argv)
