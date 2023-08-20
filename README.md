# Use-Module
[![PowerShell](https://img.shields.io/badge/Code-PowerShell-blue?&style=flat-square&logo=powershell)](https://learn.microsoft.com/en-us/powershell/)

Check for, and if required, install and/or import specified module(s) for use.

---

## DESCRIPTION

If modules are already installed and imported, no action is taken.  
If modules are already installed but not imported, they are simply imported for use.  

**Note:** Modules are installed and imported using the currentuser/local scope.

Supports specifying multiple module names via parameter or pipeline input.  
Multiple module names specified by parameter should be comma separated.  
If module names contains spaces, the name should be wrapped in quotes (e.g "Module Name").  

### NOTES

**Author  :**   Patrick Cage (patrick@patrickcage.com)  
**Version :**   1.0.0 (2022-09-28)  
**License :**   GNU General Public License (GPL) v3  

### PARAMETER ModuleName

\<string[]> The name(s) of module(s) to be installed and/or imported for use.

### EXAMPLE

```powershell
Use-Module "Module One"
```

### EXAMPLE

```powershell
Use-Module -ModuleName "Module One"
```

### EXAMPLE

```powershell
Use-Module "Module One", "Mondule Two", "Module Three"
```

### EXAMPLE

```powershell
Use-Module -ModuleName "Module One", "Module Two", "Module Three"
```

### LINKS

**Website** : https://www.patrickcage.com/use-module

---

If this has helped you, consider [buying me a coffee](https://www.buymeacoffee.com/patrickcage)