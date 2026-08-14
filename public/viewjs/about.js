$('[data-toggle="collapse-next"]').on("click", function(e)
{
	e.preventDefault();
	$(this).parent().next().collapse("toggle");
});

if ((typeof GetUriParam("tab") !== "undefined" && GetUriParam("tab") === "changelog"))
{
	$(".nav-tabs a[href='#changelog']").tab("show");
}

// Fork build time is shown as a local date + clock time (e.g. "2026-08-14 16:04"),
// not the day-bucketed "Today"/"Yesterday" that RefreshContextualTimeago gives other
// dates on this page - builds happen multiple times a day during active work,
// so knowing exactly when actually matters here. datetime is UTC (built by CI);
// moment() converts to the browser's local time automatically.
var forkBuildTime = $("#fork-build-time");
if (forkBuildTime.length && forkBuildTime.attr("datetime"))
{
	forkBuildTime.text(moment(forkBuildTime.attr("datetime")).format("YYYY-MM-DD HH:mm"));
}
