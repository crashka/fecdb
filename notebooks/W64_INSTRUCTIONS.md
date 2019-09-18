# Instructions for Running `fecdb` Jupyter Notebooks #

## Prerequisites ##

* Anaconda3 is installed (all default choices during setup is fine)
* The attached file, "`test_jupyter.ipynb`", is saved to your Desktop

## Steps ##

*Note that all of the following steps only need to be done once (except for the last one)*

### Download `fecdb` GitHub Repository ###

1. In your browser, go to: `https://github.com/crashka/fecdb`
2. Click on the "Clone or download" button
3. Choose "Download ZIP" (saves to your "Downloads" folder, by default)
4. Open the downloaded zip file (should be called "`fecdb-master.zip`")
5. Click on "Extract all" and choose your Desktop as the destination
6. In Windows Explorer, go to your Desktop and validate that the "`fecdb-master`" folder
   is there
7. Rename "`fecdb-master`" to "`fecdb`"

### Configure PostgreSQL to Trust Local Logins ###

1. Open the following file in Wordpad (or your text editor of choice): `C:\Program Files\PostgreSQL\10\data\pg_hba.conf`
2. Find the line containing the entry "`host all all 127.0.0.1/32 md5`" and change "md5" (last field) to "trust"
3. Save the file

### Set Database Connect String in Your Environment ##

1. Open a (Windows) Command Prompt and type the following (using your real PostgreSQL
   username, if different than "ethan"):

        setx DATABASE_URL "postgresql+psycopg2://ethan@127.0.0.1/fecdb"

2. If for some reason, the local login trust is not working properly (i.e. if you have
   trouble connecting during the "Test Jupyter" step below), you can set the connect
   string to include your database password (omitting the angle brackets):

        setx DATABASE_URL "postgresql+psycopg2://ethan:<password>@127.0.0.1/fecdb"

### Install Additional Python Modules ###

1. From the (Windows) Start menu, open "Anaconda Prompt" (under "Anaconda3")
2. Type the following two commands:

        conda install psycopg2
        pip install ipython-sql

### Test Jupyter ###

1. From the Anaconda Prompt window, type the following:

        cd Desktop
        jupyter notebook

2. Jupyter should launch in a browser window
3. In Jupyter, you should see "`test_jupyter.ipynb`"; open it (click on the link) and
   follow directions


### Run `fecdb` Jupyter Notebooks ###

1. Bring up an Anaconda Prompt and type the following (assuming the `fecdb` repository was
   extracted to your Desktop):

        cd Desktop\fecdb\notebooks
        jupyter notebook

3. You should see the "`define_context`" and "`query_context`" folders containing the
   notebooks; click on the link for any notebook to start it (will open in a new tab in
   the browser)
2. You can shutdown Jupyter either by clicking "Quit" in Jupyter, or by typing Ctrl-C
   *twice* in the Anaconda Prompt window where you started Jupyter
