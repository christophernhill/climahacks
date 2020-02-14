import requests
import time
import json
from github import Github
import pandas as pd
import os
gt = os.getenv('GIT_TOKEN') # Get this from your Github Oauth tokens
print(gt)

# Get list of all PRs
gTok=gt
client = Github(gTok)
client.get_user().get_repos()
repo = client.get_repo("climate-machine/CLIMA")
pulls = repo.get_pulls(state='all', sort='created')

# Ingest into Pandas
df = pd.DataFrame(
      ( [p, p.title, p.created_at, p.merged_at, p.closed_at] for p in pulls ) ,
      columns=('pr', 'title', 'created', 'merged', 'closed')
     )
print(df.count() )

## Extract some values

# Created date and cummulative counter
x_values=df["created"]
y_values=x_values.index+1

# Closed date (if there is one) with cummulative counter (yc_) and index of corresponding PR (ycc_)
xc_values=df[pd.notnull(df["closed"])]["closed"].sort_values()
yc_values=list(range(1,df.count()["closed"]+1))
ycc_values=xc_values.index+1

# Not closed yet and PR index
xnc_values=df[pd.isnull(df["closed"])]["created"].sort_values()
ync_values=xnc_values.index+1

# Make a plot
import matplotlib.pyplot as plt
import matplotlib.dates  as mdates
import datetime
plt.figure(figsize=(30,30),dpi=300)
ms=6
ax = plt.gca()
formatter = mdates.DateFormatter("%Y")
# plt.plot(x_values, y_values,'*')
ax.xaxis.set_major_formatter(formatter)
locator = mdates.DayLocator()
years = mdates.YearLocator() 
months=mdates.MonthLocator() 
ax.xaxis.set_major_locator(years)
ax.xaxis.set_minor_locator(months)
ax.grid(linestyle='-', linewidth='0.5', color='red')
ax.grid(which='minor', linestyle=':', linewidth='0.5', color='black')
# Draw line with "x". x-axis is when PR was closed and y is create index of PR
# This gives a sense of time between create and close. It is hard to tell how
# PR close count is tracking PR create count though.
plt.plot(xc_values, ycc_values,'x',label='Individual PR close dates',c='b',alpha=0.4,markersize=ms)
# Draw line with ".". x-axis is when PR was closed and y is sequence in close order.
# This gives a sense of how create rate and close rate are diverging
plt.plot(xc_values, yc_values,'.',label='PR close, total count v date',c='g',markersize=ms)
# Drawline with "*". x-axis is when PR was created and y-axis is counter.
# This shows PR create count and rate
plt.plot(x_values, y_values,'^',label='PR create, total count v date',c='k',markersize=ms)
# Still open PRs
plt.plot(xnc_values, ync_values,'^',label='PR still open',c='r',markersize=ms)

ax.legend(fontsize='x-large')
plt.show()
