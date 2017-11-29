package com.paraxialtech.vapals.vista.expectit;

/*
 * #%L
 * ExpectIt
 * %%
 * Copyright (C) 2014 Alexey Gavrilov and contributors
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * #L%
 */

import java.util.Collections;
import java.util.List;
import net.sf.expectit.MultiResult;
import net.sf.expectit.Result;

/**
 * A matcher implementation for multiple operations.
 *
 * Redefined in terms of the VA-PALS project because the original is
 * inexplicably package-private. This implementation is also package-private for
 * two reasons:
 * <ul>
 * <li>to minimize code drift if the ExpectIt library changes on us
 * <li>because we're not publishing this as part of our API (like ExpectIt), so
 * we can get away with it.
 *
 * @author Keith Powers
 */
class MultiResultImpl2 implements MultiResult {
    private final List<Result> results;
    private final Result delegate;
    private final boolean canStopMatching;

    MultiResultImpl2(Result delegate, List<Result> results) {
        this.delegate = delegate;
        this.results = results;
        this.canStopMatching = canStopMatching(results);
    }

    @Override
    public String getInput() {
        return delegate.getInput();
    }

    @Override
    public boolean isSuccessful() {
        return delegate.isSuccessful();
    }

    @Override
    public String getBefore() {
        return delegate.getBefore();
    }

    @Override
    public boolean canStopMatching() {
        return canStopMatching;
    }

    @Override
    public int start() {
        return delegate.start();
    }

    @Override
    public int start(int group) {
        return delegate.start(group);
    }

    @Override
    public int end() {
        return delegate.end();
    }

    @Override
    public int end(int group) {
        return delegate.end(group);
    }

    @Override
    public String group() {
        return delegate.group();
    }

    @Override
    public String group(int group) {
        return delegate.group(group);
    }

    @Override
    public int groupCount() {
        return delegate.groupCount();
    }

    @Override
    public List<Result> getResults() {
        return Collections.unmodifiableList(results);
    }

    static boolean canStopMatching(List<Result> results) {
        boolean canStopMatching = false;
        for (Result r : results) {
            if (!r.canStopMatching()) {
                return false;
            }
            canStopMatching = true;
        }
        return canStopMatching;
    }

    @Override
    public String toString() {
        return "MultiResultImpl2{"
                + "results=" + results
                + ", delegate=" + delegate
                + ", canStopMatching=" + canStopMatching + '}';
    }
}
