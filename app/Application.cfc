component {
    this.name = "rusty";
    this.customTagPaths = [
        getDirectoryFromPath(getCurrentTemplatePath()) & "compatibility/customtags"
    ];

    public boolean function onApplicationStart() {
        return true;
    }
}
