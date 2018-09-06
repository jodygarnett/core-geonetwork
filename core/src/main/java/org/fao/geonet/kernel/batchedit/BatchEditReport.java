package org.fao.geonet.kernel.batchedit;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class BatchEditReport implements Serializable {

	private List<String> errorInfo;
	private List<String> processInfo;

	public List<String> getErrorInfo() {
		if (errorInfo == null) {
			errorInfo = new ArrayList<>();
		}
		return errorInfo;
	}

	public List<String> getProcessInfo() {
		if (processInfo == null) {
			processInfo = new ArrayList<>();
		}
		return processInfo;
	}

}
