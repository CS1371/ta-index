# TA Index

The TA Index is the central website for students to see any pertinent information about their instructors,
including (but not limited to):

* Name
* Picture
* Hobbies
* Fun Facts
* Help Desk Hours
* Contact Information
* Basic Profile

## Loading Data

TA Data is to be organized into a JSON file called `teachers.json`. Below is a reference:

``` json
{
    "gtUsername": "gburdell3",
    "name": "George P. Burdell",
    "major": "3rd Year MATLAB Engineering",
    "section": {
        "section": "SectionName",
        "location": "Section Location",
        "time": "D Start pm - End pm (example: W 4:30 pm - 5:45 pm)"
    },
    "helpDesk": [
        {
            "day": "dayofweek (example: monday)",
            "time": "Start pm - End pm (example: 4 pm - 6 pm)"
        },
        {
            "day": "dayofweek",
            "time": "Start pm - End pm"
        }
    ],
    "title": "Official title (blank if no title. Example: Head TA)",
    "funFacts": [
        {
            "question": "Question Text",
            "answer": "Question Answer&#39; is how you put a quote (single and double)"
        }
    ]
}
```

To lead this data, we collect it via a form on Google Drive. However, to convert this data,
you must use `convertToIndex.m`.

## `convertToIndex`

`convertToIndex` takes in the three separate sources of data as Excel workbooks. The format of
these workbooks must strictly follow this specification, unless otherwise noted.

The three workbooks provide:
* Basic TA information
* Help Desk Hours
* TA Fun Facts
* TA Sections

How each is read, and what this means for the end product, is detailed below.

### Basic TA Information

This workbook _must_ have the following information, though it can be in any order (but the headings must be identical):

* GT Username: The person's standard GT Username (i.e., gburdell3)
* Name: The person's full name
* Major: The person's Major
* Title: The person's title, such as "Head TA"
* Section: The section this person teaches, or blank for no section.

> Note: If `Name` is the keyword `DELETE`, then the TA is **removed from the index. Be very sure!**

### Help Desk Hours

This workbook _must_ have the following information:

* GT Username: The information that ties this back to the Basic TA Information page
* Day: The Day this record represents for Help Desk
* Start: The start time for this person's help desk, in 12 hour format, with or without leading zeros
* Stop: The stop time for this person's help desk, in the same format as start.

It is unlikely the original workbook will be in this format. There is a function called `help2standard` which will
convert the HelpDesk workbook into this standard format - you should look at its documentation for more information.

### TA Fun Facts

This workbook _must_ have the following information:

* GT Username: This ties it back to the Basic TA Information
* Question: The question that was asked
* Answer: The answer given.

> Note: If **Answer** is the keyword `DELETE`, then the question answer pair is deleted from the existing bank.

As with Help Desk Hours, it is unlikely the original workbook is in this format. For more information on
how to rectify this, see `fun2standard`.

### TA Sections

This workbook _must_ have the following information:

* Section Name: Must match exactly with the section in the Basic TA Information
* Section Location: Where this section is located
* Section Time: Formatted in accordance with the JSON specification
