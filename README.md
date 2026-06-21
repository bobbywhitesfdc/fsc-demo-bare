# FSC Demo

Will create a scratch org with FSC licenses.
Assigns the minimum required permissionSet

# Configuration
This project reads environment-specific values from `project.properties`, which
is **gitignored** so usernames and internal Dev Hub aliases are never committed.
Create your own copy from the tracked template and edit the values:

<code>cp project.properties.example project.properties</code>

| Property | Required | Description |
| --- | --- | --- |
| `default.env.alias` | yes | Alias for the scratch org (used as `--target-org`). |
| `user.admin` | yes | Globally-unique scratch org username. Bump it if a create fails with C-1007 (recently-deleted usernames stay reserved for a while). |
| `devhub.alias` | no | Dev Hub to create against; must have FSC + Experience Cloud/Community licenses. Omit to use the sf CLI default Dev Hub. |

# Pre-work
In a Mac OS/Linux environment, you must grant read and execute permissions first!
<code>chmod u+x .orgInit.sh</code>

# Creating the scratch org instance and pushing basic customizations
<code>
./orgInit.sh
</code>

# Load some Sampledata
<code>
  ./load_sample_data.sh
</code>
