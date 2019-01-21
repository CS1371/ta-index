# TA Index

The TA Index is the central website for students to see any pertinent information about their instructors,
including (but not limited to):

* Name
* Picture
* Fun Facts
* Help Desk Hours
* Contact Information
* Basic Profile

## Usage

Using `convertToIndex` is relatively straightforward. You will need 4 Excel
sheets, and optionally one JSON file.

The four Excel sheets are detailed below, as well as the `teachers.json`
optional input.

1. First, download the Excel sheets and the previous `teachers.json`. It is recommended to rename the previous teachers.json to `teachers_previous.json`
2. Run `convertToIndex`:

``` matlab
convertToIndex('path/to/basic.xlsx', 'path/to/helpdesk.xlsx', 'path/to/funfacts.xlsx', 'path/to/sections.xlsx', 'path/to/previous_teachers.json');
```

3. Upload the new `teachers.json` (which `convertToIndex` creates) to the server

> Note: The path will be `/httpdocs/TAIndex/teachers.json`

4. Upload any new pictures. Pictures must _always_ be named `<gtusername>.jpg`.

> **Images**: Every TA has two images - a Headshot and a Background. To upload a Headshot,
> upload the `<gtusername>.jpg` to `/httpdocs/TAIndex/images/TA_Pics/`. To upload a Background,
> upload the `<gtusername>.jpg` to `/httpdocs/TAIndex/images/TAHorizontalPics/`.

## Loading Data

TA Data is to be organized into a JSON file called `teachers.json`. Below is a reference:

``` json
{
    "gtUsername": "gburdell3",
    "name": "George P. Burdell",
    "major": "3rd Year MATLAB Engineering",
    "section": {
        "name": "SectionName",
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
            "answer": "Question Answer\"; is how you put a quote (double)"
        }
    ]
}
```

To lead this data, we collect it via a form on Google Drive. However, to convert this data,
you must use `convertToIndex.m`.

## `convertToIndex`

`convertToIndex` takes in the four separate sources of data as Excel workbooks. The format of
these workbooks must strictly follow this specification, unless otherwise noted.

The four workbooks provide:
* Basic TA information
* Help Desk Hours
* TA Fun Facts
* TA Sections

Optionally, you can also include an existing TA index package - the `teachers.json`.
This will enable the function to use past answers for the Fun Facts.

How each is read, and what this means for the end product, is detailed below.

### Basic TA Information

This workbook _must_ have the following information, though it can be in any order (but the headings must be identical):

* GT Username: The person's standard GT Username (i.e., gburdell3)
* Name: The person's full name
* Major: The person's Year & Major
* Title: The person's title, such as "Head TA"

### Help Desk Hours

This workbook _must_ have the following information:

* GT Username: The information that ties this back to the Basic TA Information page
* Day: The Day this record represents for Help Desk
* Start: The start time for this person's help desk, in 12 hour format, with or without leading zeros
* Stop: The stop time for this person's help desk, in the same format as start.

### TA Fun Facts

This workbook _must_ have the following information:

* GT Username: This ties it back to the Basic TA Information
* Question: The question that was asked
* Answer: The answer given.

> Note: If **Answer** is the keyword `DELETE`, then the question answer pair is deleted from the existing bank.

As with Help Desk Hours, it is unlikely the original workbook is in this format. For more information on
how to rectify this, see `fun2standard`, a function included in `convertToIndex.m`.

For more information, try `help convertToIndex`.

### TA Sections

This workbook _must_ have the following information:

* Name: Must match exactly with the section in the Basic TA Information
* Location: Where this section is located
* Time: Formatted in accordance with the JSON specification
* First TA: The GT Username of the First TA (or blank if nobody)
* Second TA: The GT Username of the second TA (or blank if nobody)
